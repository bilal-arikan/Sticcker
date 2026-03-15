import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:image/image.dart' as img;
import '../cache/sticker_cache.dart';
import '../../core/constants/sticker_constants.dart';

class MediaProcessor {
  final StickerCache _cache;

  MediaProcessor(this._cache);

  MediaType detectMediaType(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (StickerConstants.supportedVideoFormats.contains(ext)) {
      return MediaType.video;
    }
    if (StickerConstants.supportedGifFormats.contains(ext)) {
      return MediaType.gif;
    }
    return MediaType.image;
  }

  /// Process a single image to sticker format (512x512 WEBP)
  Future<String> processImage(
    String sourcePath, {
    double? cropX,
    double? cropY,
    double? cropWidth,
    double? cropHeight,
    int targetSize = 512,
  }) async {
    final params = {
      'cropX': cropX,
      'cropY': cropY,
      'cropW': cropWidth,
      'cropH': cropHeight,
      'size': targetSize,
    };

    // Check cache
    final cached = await _cache.getCachedPath(sourcePath, params: params);
    if (cached != null) return cached;

    final outputPath = await _cache.getCachePath(sourcePath, params: params);

    // Use FFmpeg for broader format support (HEIC, TIFF, etc.)
    final cropFilter = (cropX != null && cropY != null && cropWidth != null && cropHeight != null)
        ? 'crop=${cropWidth.toInt()}:${cropHeight.toInt()}:${cropX.toInt()}:${cropY.toInt()},'
        : '';

    // For WebP/GIF: extract only first frame to avoid animated decode issues
    final ext = sourcePath.split('.').last.toLowerCase();
    final frameFilter = (ext == 'webp' || ext == 'gif') ? '-vframes 1 ' : '';

    final command =
        '-i "$sourcePath" $frameFilter-vf "${cropFilter}scale=$targetSize:$targetSize:force_original_aspect_ratio=decrease,pad=$targetSize:$targetSize:(ow-iw)/2:(oh-ih)/2:color=0x00000000" -y "$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      // Fallback: try with dart image library
      return _processImageDart(sourcePath, outputPath, cropX, cropY, cropWidth, cropHeight, targetSize);
    }

    return outputPath;
  }

  Future<String> _processImageDart(
    String sourcePath,
    String outputPath,
    double? cropX,
    double? cropY,
    double? cropWidth,
    double? cropHeight,
    int targetSize,
  ) async {
    final bytes = await File(sourcePath).readAsBytes();
    img.Image? image;
    try {
      image = img.decodeImage(bytes);
    } catch (e) {
      // Some WebP files (animated, VP8L) fail in dart image lib
      // Try decoding as PNG fallback via FFmpeg first frame extraction
      final fallbackPath = outputPath.replaceAll(RegExp(r'\.\w+$'), '_fb.png');
      final fbSession = await FFmpegKit.execute(
          '-i "$sourcePath" -vframes 1 -y "$fallbackPath"');
      final fbCode = await fbSession.getReturnCode();
      if (ReturnCode.isSuccess(fbCode) && await File(fallbackPath).exists()) {
        final fbBytes = await File(fallbackPath).readAsBytes();
        image = img.decodeImage(fbBytes);
        await File(fallbackPath).delete().catchError((_) => File(fallbackPath));
      }
    }
    if (image == null) throw Exception('Failed to decode image: $sourcePath');

    // Crop if specified
    if (cropX != null && cropY != null && cropWidth != null && cropHeight != null) {
      image = img.copyCrop(image,
          x: cropX.toInt(),
          y: cropY.toInt(),
          width: cropWidth.toInt(),
          height: cropHeight.toInt());
    }

    // Resize to fit within targetSize, maintaining aspect ratio
    if (image.width > targetSize || image.height > targetSize) {
      image = img.copyResize(image,
          width: image.width > image.height ? targetSize : null,
          height: image.height >= image.width ? targetSize : null,
          interpolation: img.Interpolation.linear);
    }

    // Encode as PNG (will be converted to WebP via FFmpeg if needed)
    final pngBytes = img.encodePng(image);
    await File(outputPath).writeAsBytes(pngBytes);

    return outputPath;
  }

  /// Process video to animated sticker (WEBM VP9 for Telegram)
  Future<String> processVideoToWebm(
    String sourcePath, {
    int? trimStartMs,
    int? trimEndMs,
    int targetSize = 512,
    int maxDurationSec = 3,
  }) async {
    final params = {
      'trimStart': trimStartMs,
      'trimEnd': trimEndMs,
      'size': targetSize,
      'maxDur': maxDurationSec,
      'format': 'webm',
    };

    final cached = await _cache.getCachedPath(sourcePath, params: params);
    if (cached != null) return cached;

    final outputPath = await _cache.getCachePath(sourcePath, ext: 'webm', params: params);

    final startSec = (trimStartMs ?? 0) / 1000.0;
    final duration = trimEndMs != null
        ? ((trimEndMs - (trimStartMs ?? 0)) / 1000.0).clamp(0.1, maxDurationSec.toDouble())
        : maxDurationSec.toDouble();

    final command =
        '-ss $startSec -i "$sourcePath" -t $duration '
        '-vf "scale=$targetSize:$targetSize:force_original_aspect_ratio=decrease,pad=$targetSize:$targetSize:(ow-iw)/2:(oh-ih)/2:color=0x00000000" '
        '-c:v libvpx-vp9 -b:v 400k -an -r 30 -pix_fmt yuva420p '
        '-y "$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      throw Exception('Failed to process video to WEBM');
    }

    // Check file size (max 256KB for Telegram)
    final fileSize = await File(outputPath).length();
    if (fileSize > StickerConstants.telegramMaxVideoSizeKB * 1024) {
      // Re-encode with lower bitrate
      final reducedPath = outputPath.replaceAll('.webm', '_r.webm');
      final reduceCommand =
          '-i "$outputPath" -c:v libvpx-vp9 -b:v 200k -an -r 24 -y "$reducedPath"';
      await FFmpegKit.execute(reduceCommand);
      await File(outputPath).delete();
      await File(reducedPath).rename(outputPath);
    }

    return outputPath;
  }

  /// Process video/GIF to animated WebP (for WhatsApp)
  Future<String> processToAnimatedWebp(
    String sourcePath, {
    int? trimStartMs,
    int? trimEndMs,
    int targetSize = 512,
    double? cropX,
    double? cropY,
    double? cropWidth,
    double? cropHeight,
    int rotationCount = 0,
  }) async {
    final params = {
      'trimStart': trimStartMs,
      'trimEnd': trimEndMs,
      'size': targetSize,
      'format': 'awebp',
      'cropX': cropX,
      'cropY': cropY,
      'cropW': cropWidth,
      'cropH': cropHeight,
      'rot': rotationCount,
    };

    final cached = await _cache.getCachedPath(sourcePath, params: params);
    if (cached != null) return cached;

    final outputPath = await _cache.getCachePath(sourcePath, params: params);

    final startSec = (trimStartMs ?? 0) / 1000.0;
    final durationArg = trimEndMs != null
        ? '-t ${((trimEndMs - (trimStartMs ?? 0)) / 1000.0).clamp(0.1, 7.0)}'
        : '-t 7';

    // Build video filter chain: rotation FIRST, then crop, then scale
    final filters = <String>[];
    // Apply rotation (0=none, 1=90°CW, 2=180°, 3=270°CW)
    if (rotationCount == 1) {
      filters.add('transpose=1');
    } else if (rotationCount == 2) {
      filters.add('transpose=1,transpose=1');
    } else if (rotationCount == 3) {
      filters.add('transpose=2');
    }
    // Apply crop AFTER rotation (coordinates are relative to rotated frame)
    if (cropX != null && cropY != null && cropWidth != null && cropHeight != null) {
      filters.add('crop=${cropWidth!.toInt()}:${cropHeight!.toInt()}:${cropX!.toInt()}:${cropY!.toInt()}');
    }
    filters.add('scale=$targetSize:$targetSize:force_original_aspect_ratio=decrease');
    filters.add('pad=$targetSize:$targetSize:(ow-iw)/2:(oh-ih)/2:color=0x00000000');

    final vf = filters.join(',');

    debugPrint('[MediaProcessor] processToAnimatedWebp: source=$sourcePath');
    debugPrint('[MediaProcessor] filters: $vf, start=$startSec, duration=$durationArg');
    debugPrint('[MediaProcessor] crop=($cropX,$cropY,$cropWidth,$cropHeight) rotation=${rotationCount * 90}°');

    // Check source file exists and has content
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Source file not found: $sourcePath');
    }
    final sourceSize = await sourceFile.length();
    debugPrint('[MediaProcessor] source file size: $sourceSize bytes');
    if (sourceSize == 0) {
      throw Exception('Source file is empty (0 bytes): $sourcePath');
    }

    // Build seek argument - skip -ss for position 0 (can interfere with WebP demuxer)
    final seekArg = startSec > 0 ? '-ss $startSec ' : '';

    // Try multiple FFmpeg strategies for encoding animated WebP
    final strategies = [
      // Strategy 1: libwebp_anim encoder (standard)
      '${seekArg}-i "$sourcePath" $durationArg '
      '-vf "$vf" '
      '-vcodec libwebp_anim -lossless 0 -compression_level 3 -quality 70 -loop 0 '
      '-an -y "$outputPath"',
      // Strategy 2: libwebp encoder with preset
      '${seekArg}-i "$sourcePath" $durationArg '
      '-vf "$vf" '
      '-vcodec libwebp -lossless 0 -compression_level 3 -quality 70 -loop 0 -preset photo '
      '-an -y "$outputPath"',
      // Strategy 3: increased analyzeduration/probesize for animated WebP input
      '-analyzeduration 100M -probesize 100M ${seekArg}-i "$sourcePath" $durationArg '
      '-vf "$vf" '
      '-vcodec libwebp_anim -lossless 0 -compression_level 3 -quality 70 -loop 0 '
      '-an -y "$outputPath"',
      // Strategy 4: force concat demuxer approach - read as image sequence
      '-framerate 15 -f image2pipe -c:v webp ${seekArg}-i "$sourcePath" $durationArg '
      '-vf "$vf" '
      '-vcodec libwebp_anim -lossless 0 -quality 70 -loop 0 '
      '-an -y "$outputPath"',
    ];

    String? lastLogs;
    for (int i = 0; i < strategies.length; i++) {
      debugPrint('[MediaProcessor] FFmpeg strategy ${i + 1}: ${strategies[i]}');
      final session = await FFmpegKit.execute(strategies[i]);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        final outFile = File(outputPath);
        if (await outFile.exists() && await outFile.length() > 0) {
          debugPrint('[MediaProcessor] Strategy ${i + 1} succeeded');
          break;
        }
      }

      lastLogs = await session.getLogsAsString();
      debugPrint('[MediaProcessor] Strategy ${i + 1} failed');

      if (i == strategies.length - 1) {
        debugPrint('[MediaProcessor] All strategies failed. Last logs: $lastLogs');
        throw Exception('Failed to process to animated WebP.\nSource: ${sourcePath.split('/').last}\nFFmpeg: ${lastLogs?.substring(0, (lastLogs.length).clamp(0, 500))}');
      }
    }

    // Validate output file
    final outputFile = File(outputPath);
    if (!await outputFile.exists()) {
      throw Exception('Output file was not created: $outputPath');
    }
    final outputSize = await outputFile.length();
    debugPrint('[MediaProcessor] output file size: $outputSize bytes');
    if (outputSize == 0) {
      await outputFile.delete().catchError((_) => outputFile);
      throw Exception('Output file is empty (0 bytes). Source: ${sourcePath.split('/').last}');
    }

    return outputPath;
  }

  /// Rotate image 90 degrees clockwise using FFmpeg
  /// For WebP/GIF: preserves all frames (animation)
  /// For other formats: extracts single frame as PNG
  /// Rotate image by [rotationCount] * 90° clockwise.
  /// For animated media, always pass the ORIGINAL source (not a previously rotated output)
  /// because FFmpeg cannot read animated WebP as input.
  Future<String> rotateImage(String sourcePath, {bool preserveAnimation = false, int rotationCount = 1}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = sourcePath.split('.').last.toLowerCase();
    final isAnimatable = preserveAnimation || ext == 'webp' || ext == 'gif';

    // Normalize rotation to 1-3 (0 = no rotation, should not be called)
    final effectiveRotation = rotationCount % 4;
    if (effectiveRotation == 0) {
      debugPrint('[MediaProcessor] rotateImage: no rotation needed');
      return sourcePath;
    }

    // Build transpose filter chain for the total rotation
    // transpose=1 = 90° CW, applied N times for N*90°
    String vf;
    if (effectiveRotation == 1) {
      vf = 'transpose=1';
    } else if (effectiveRotation == 2) {
      vf = 'transpose=1,transpose=1';
    } else {
      // 3 = 270° CW = 90° CCW
      vf = 'transpose=2';
    }

    if (isAnimatable) {
      final outputPath = await _cache.getCachePath(sourcePath, ext: 'webp', params: {'rotate': timestamp});

      debugPrint('[MediaProcessor] rotateImage (animated): $sourcePath, rotation=${effectiveRotation * 90}°');

      // Try libwebp_anim first, fallback to libwebp
      var command =
          '-i "$sourcePath" -vf "$vf" '
          '-vcodec libwebp_anim -lossless 0 -quality 70 -loop 0 -an -y "$outputPath"';

      var session = await FFmpegKit.execute(command);
      var returnCode = await session.getReturnCode();

      if (!ReturnCode.isSuccess(returnCode)) {
        final logs1 = await session.getLogsAsString();
        debugPrint('[MediaProcessor] rotate libwebp_anim failed: $logs1');

        command =
            '-i "$sourcePath" -vf "$vf" '
            '-vcodec libwebp -lossless 0 -quality 70 -loop 0 -preset photo -an -y "$outputPath"';
        session = await FFmpegKit.execute(command);
        returnCode = await session.getReturnCode();

        if (!ReturnCode.isSuccess(returnCode)) {
          final logs2 = await session.getLogsAsString();
          debugPrint('[MediaProcessor] rotate libwebp fallback failed: $logs2');
          throw Exception('Failed to rotate animated image.\nFFmpeg: ${logs2?.substring(0, (logs2.length).clamp(0, 500))}');
        }
      }

      // Validate output
      final outFile = File(outputPath);
      if (!await outFile.exists() || await outFile.length() == 0) {
        throw Exception('Rotated file is empty or missing');
      }
      debugPrint('[MediaProcessor] rotate OK: ${await outFile.length()} bytes');

      return outputPath;
    } else {
      final outputPath = await _cache.getCachePath(sourcePath, ext: 'png', params: {'rotate': timestamp});

      final command =
          '-i "$sourcePath" -vframes 1 -vf "$vf" -y "$outputPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (!ReturnCode.isSuccess(returnCode)) {
        throw Exception('Failed to rotate image');
      }

      return outputPath;
    }
  }

  /// Extract first frame of a video/GIF/animated WebP as PNG
  Future<String> extractFirstFrame(String sourcePath) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = await _cache.getCachePath(sourcePath, ext: 'png', params: {'frame': timestamp});

    debugPrint('[MediaProcessor] extractFirstFrame: $sourcePath');

    // Try standard extraction
    final command = '-i "$sourcePath" -vframes 1 -y "$outputPath"';
    var session = await FFmpegKit.execute(command);
    var returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode) && await File(outputPath).exists()) {
      debugPrint('[MediaProcessor] extractFirstFrame OK: $outputPath');
      return outputPath;
    }

    // Log FFmpeg error
    final logs = await session.getLogsAsString();
    debugPrint('[MediaProcessor] extractFirstFrame FFmpeg failed: $logs');

    // Fallback: try with -frames:v 1 and explicit format
    final command2 = '-i "$sourcePath" -frames:v 1 -f image2 -y "$outputPath"';
    session = await FFmpegKit.execute(command2);
    returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode) && await File(outputPath).exists()) {
      debugPrint('[MediaProcessor] extractFirstFrame fallback OK');
      return outputPath;
    }

    // Fallback 2: try Dart image library
    debugPrint('[MediaProcessor] extractFirstFrame trying Dart image lib');
    try {
      final bytes = await File(sourcePath).readAsBytes();
      final image = img.decodeImage(bytes);
      if (image != null) {
        final pngBytes = img.encodePng(image);
        await File(outputPath).writeAsBytes(pngBytes);
        debugPrint('[MediaProcessor] extractFirstFrame Dart lib OK');
        return outputPath;
      }
    } catch (e) {
      debugPrint('[MediaProcessor] extractFirstFrame Dart lib failed: $e');
    }

    final logs2 = await session.getLogsAsString();
    throw Exception('Failed to extract first frame from: ${sourcePath.split('/').last}\nFFmpeg: $logs2');
  }

  /// Generate thumbnail for a sticker
  Future<String> generateThumbnail(String sourcePath, {int size = 128}) async {
    final thumbnailPath = await _cache.getThumbnailPath(sourcePath);

    if (await File(thumbnailPath).exists()) return thumbnailPath;

    final mediaType = detectMediaType(sourcePath);

    if (mediaType == MediaType.image) {
      final command =
          '-i "$sourcePath" -vf "scale=$size:$size:force_original_aspect_ratio=decrease" -y "$thumbnailPath"';
      await FFmpegKit.execute(command);
    } else {
      // For video/gif, extract first frame
      final command =
          '-i "$sourcePath" -vframes 1 -vf "scale=$size:$size:force_original_aspect_ratio=decrease" -y "$thumbnailPath"';
      await FFmpegKit.execute(command);
    }

    return thumbnailPath;
  }

  /// Batch process multiple files
  Stream<ProcessingProgress> batchProcess(
    List<String> sourcePaths, {
    required int packId,
    int targetSize = 512,
  }) async* {
    for (int i = 0; i < sourcePaths.length; i++) {
      final path = sourcePaths[i];
      yield ProcessingProgress(
        current: i,
        total: sourcePaths.length,
        currentFile: path,
        status: ProcessingStatus.processing,
      );

      try {
        final mediaType = detectMediaType(path);
        String processedPath;

        switch (mediaType) {
          case MediaType.image:
            processedPath = await processImage(path, targetSize: targetSize);
            break;
          case MediaType.video:
          case MediaType.gif:
            processedPath = await processToAnimatedWebp(path, targetSize: targetSize);
            break;
        }

        await generateThumbnail(path);

        yield ProcessingProgress(
          current: i + 1,
          total: sourcePaths.length,
          currentFile: path,
          processedPath: processedPath,
          status: ProcessingStatus.done,
        );
      } catch (e) {
        yield ProcessingProgress(
          current: i + 1,
          total: sourcePaths.length,
          currentFile: path,
          status: ProcessingStatus.error,
          error: e.toString(),
        );
      }
    }
  }
}

enum ProcessingStatus { processing, done, error }

class ProcessingProgress {
  final int current;
  final int total;
  final String currentFile;
  final String? processedPath;
  final ProcessingStatus status;
  final String? error;

  ProcessingProgress({
    required this.current,
    required this.total,
    required this.currentFile,
    this.processedPath,
    required this.status,
    this.error,
  });

  double get progress => total > 0 ? current / total : 0;
}
