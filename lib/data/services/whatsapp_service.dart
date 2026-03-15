import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import '../models/sticker.dart';
import '../models/sticker_pack.dart';
import '../../core/constants/sticker_constants.dart';

class WhatsAppService {
  static const _channel = MethodChannel('com.bilal.sticcker/whatsapp');

  /// Detect if a file is actually animated by checking magic bytes and extension
  Future<bool> _isFileAnimated(String path) async {
    final ext = path.split('.').last.toLowerCase();
    // Video formats are always animated
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) return true;
    // GIF is always animated
    if (ext == 'gif') return true;

    try {
      final file = File(path);
      final raf = await file.open(mode: FileMode.read);
      final header = Uint8List(30);
      await raf.readInto(header);

      // GIF87a or GIF89a (even if extension is wrong)
      if (header[0] == 0x47 && header[1] == 0x49 && header[2] == 0x46) {
        await raf.close();
        return true;
      }

      // Animated WebP detection:
      // RIFF....WEBP header, then look for VP8X chunk with animation flag
      if (header[0] == 0x52 && header[1] == 0x49 && header[2] == 0x46 && header[3] == 0x46 && // RIFF
          header[8] == 0x57 && header[9] == 0x45 && header[10] == 0x42 && header[11] == 0x50) { // WEBP
        // Read more bytes to find VP8X chunk (usually at offset 12)
        // VP8X chunk: bytes 12-15 = "VP8X", byte 20 = flags
        // Animation flag is bit 1 (0x02) of the flags byte
        if (header.length >= 21 &&
            header[12] == 0x56 && header[13] == 0x50 && header[14] == 0x38 && header[15] == 0x58) { // VP8X
          final flags = header[20];
          final isAnimated = (flags & 0x02) != 0;
          debugPrint('WhatsApp: WebP file $path - VP8X flags=0x${flags.toRadixString(16)}, animated=$isAnimated');
          await raf.close();
          return isAnimated;
        }

        // If no VP8X at offset 12, scan further (up to 100 bytes)
        final extHeader = Uint8List(100);
        await raf.setPosition(12);
        final bytesRead = await raf.readInto(extHeader);
        await raf.close();

        for (int i = 0; i < bytesRead - 8; i++) {
          if (extHeader[i] == 0x56 && extHeader[i + 1] == 0x50 &&
              extHeader[i + 2] == 0x38 && extHeader[i + 3] == 0x58) { // VP8X
            // Flags are 8 bytes after chunk name (4 name + 4 size)
            if (i + 8 < bytesRead) {
              final flags = extHeader[i + 8];
              final isAnimated = (flags & 0x02) != 0;
              debugPrint('WhatsApp: WebP file $path - VP8X found at ${i + 12}, flags=0x${flags.toRadixString(16)}, animated=$isAnimated');
              return isAnimated;
            }
          }
          // Also check for ANIM chunk directly
          if (extHeader[i] == 0x41 && extHeader[i + 1] == 0x4E &&
              extHeader[i + 2] == 0x49 && extHeader[i + 3] == 0x4D) { // ANIM
            debugPrint('WhatsApp: WebP file $path - ANIM chunk found, animated=true');
            return true;
          }
        }

        await raf.close();
        return false;
      }

      await raf.close();
    } catch (e) {
      debugPrint('WhatsApp: Error checking animation for $path: $e');
    }
    return false;
  }

  Future<String> _getFilesDir() async {
    final path = await _channel.invokeMethod<String>('getFilesDir');
    if (path == null) throw Exception('filesDir alinamadi');
    return path;
  }

  /// Resize static image to target size with padding, then compress to WebP
  Future<void> _convertStaticToWebp(String inputPath, String outputPath, int targetSize, int maxKB) async {
    final bytes = await File(inputPath).readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) throw Exception('Resim acilamadi: $inputPath');

    // Scale to fit within targetSize
    if (image.width > targetSize || image.height > targetSize || image.width != image.height) {
      final scale = targetSize / (image.width > image.height ? image.width : image.height);
      final newW = (image.width * scale).round().clamp(1, targetSize);
      final newH = (image.height * scale).round().clamp(1, targetSize);
      image = img.copyResize(image, width: newW, height: newH, interpolation: img.Interpolation.linear);
    }

    // Pad to exact targetSize x targetSize with transparent background
    if (image.width != targetSize || image.height != targetSize) {
      final padded = img.Image(width: targetSize, height: targetSize, numChannels: 4);
      img.fill(padded, color: img.ColorRgba8(255, 255, 255, 0));
      final offsetX = (targetSize - image.width) ~/ 2;
      final offsetY = (targetSize - image.height) ~/ 2;
      img.compositeImage(padded, image, dstX: offsetX, dstY: offsetY);
      image = padded;
    }

    // Save as temporary PNG
    final tempPngPath = '$outputPath.tmp.png';
    await File(tempPngPath).writeAsBytes(img.encodePng(image));

    // Compress to WebP using flutter_image_compress (native)
    for (int quality = 80; quality >= 10; quality -= 15) {
      final result = await FlutterImageCompress.compressAndGetFile(
        tempPngPath,
        outputPath,
        format: CompressFormat.webp,
        quality: quality,
        minWidth: targetSize,
        minHeight: targetSize,
      );

      if (result != null) {
        final size = await result.length();
        debugPrint('WhatsApp: static encoded at q=$quality -> ${size ~/ 1024}KB');
        if (size <= maxKB * 1000) break;
      }
    }

    // Clean up temp PNG
    final tempFile = File(tempPngPath);
    if (await tempFile.exists()) await tempFile.delete();

    // Verify output exists
    if (!await File(outputPath).exists()) {
      throw Exception('WebP dosyasi olusturulamadi');
    }

    final finalSize = await File(outputPath).length();
    if (finalSize > maxKB * 1000) {
      debugPrint('WhatsApp: WARNING - still ${finalSize ~/ 1024}KB (max ${maxKB}KB)');
    }
  }

  /// Check if file is a WebP (by magic bytes)
  Future<bool> _isWebpFile(String path) async {
    try {
      final raf = await File(path).open(mode: FileMode.read);
      final header = Uint8List(12);
      await raf.readInto(header);
      await raf.close();
      return header[0] == 0x52 && header[1] == 0x49 && header[2] == 0x46 && header[3] == 0x46 &&
             header[8] == 0x57 && header[9] == 0x45 && header[10] == 0x42 && header[11] == 0x50;
    } catch (_) {
      return false;
    }
  }

  /// Extract frames from animated image (WebP/GIF) using Dart image package,
  /// save as PNGs, then reassemble with FFmpeg libwebp encoder
  Future<bool> _reencodeViaFrameExtraction(String inputPath, String outputPath, int targetSize, int maxKB) async {
    final bytes = await File(inputPath).readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      debugPrint('WhatsApp: Failed to decode image');
      return false;
    }

    final frames = decoded.frames;
    if (frames.length <= 1) {
      debugPrint('WhatsApp: Not animated (${frames.length} frames)');
      return false;
    }

    debugPrint('WhatsApp: Decoded ${frames.length} frames');

    // Create temp directory for frames
    final tempDir = Directory('${outputPath}_frames');
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
    await tempDir.create(recursive: true);

    // Calculate fps from frame durations
    int totalDurationMs = 0;
    for (int i = 0; i < frames.length; i++) {
      final dur = frames[i].frameDuration;
      totalDurationMs += dur > 0 ? dur : 100; // default 100ms per frame
    }
    final avgFrameDurationMs = totalDurationMs / frames.length;
    int fps = (1000 / avgFrameDurationMs).round().clamp(1, 30);

    // Limit frame count: WhatsApp max ~7 seconds
    final maxFrames = (7 * fps).clamp(1, frames.length);

    // Extract and resize frames
    for (int i = 0; i < maxFrames; i++) {
      var frame = frames[i];

      // Resize to target
      if (frame.width != targetSize || frame.height != targetSize) {
        final scale = targetSize / (frame.width > frame.height ? frame.width : frame.height);
        final newW = (frame.width * scale).round().clamp(1, targetSize);
        final newH = (frame.height * scale).round().clamp(1, targetSize);
        frame = img.copyResize(frame, width: newW, height: newH, interpolation: img.Interpolation.linear);

        // Pad to exact targetSize
        if (frame.width != targetSize || frame.height != targetSize) {
          final padded = img.Image(width: targetSize, height: targetSize, numChannels: 4);
          img.fill(padded, color: img.ColorRgba8(0, 0, 0, 0));
          final offsetX = (targetSize - frame.width) ~/ 2;
          final offsetY = (targetSize - frame.height) ~/ 2;
          img.compositeImage(padded, frame, dstX: offsetX, dstY: offsetY);
          frame = padded;
        }
      }

      final framePath = '${tempDir.path}/frame_${i.toString().padLeft(4, '0')}.png';
      await File(framePath).writeAsBytes(img.encodePng(frame));
    }

    debugPrint('WhatsApp: Extracted $maxFrames frames at ${fps}fps');

    // Re-encode frames to animated WebP using FFmpeg + libwebp
    bool success = false;
    for (int quality = 70; quality >= 10; quality -= 20) {
      final command =
          '-framerate $fps -i "${tempDir.path}/frame_%04d.png" '
          '-vcodec libwebp -lossless 0 -compression_level 4 -quality $quality '
          '-loop 0 -preset picture -an -vsync 0 '
          '-y "$outputPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode) && await File(outputPath).exists()) {
        final size = await File(outputPath).length();
        debugPrint('WhatsApp: Re-encoded animated WebP q=$quality -> ${size ~/ 1024}KB');
        if (size <= maxKB * 1000) {
          success = true;
          break;
        }
      } else {
        final logs = await session.getLogsAsString();
        debugPrint('WhatsApp: FFmpeg frame encode error: $logs');
      }
    }

    // If still too large, try fewer frames and lower fps
    if (!success && await File(outputPath).exists()) {
      final reducedFps = (fps / 2).clamp(5, 15).toInt();
      final command =
          '-framerate $fps -i "${tempDir.path}/frame_%04d.png" '
          '-vf "fps=$reducedFps" '
          '-vcodec libwebp -lossless 0 -compression_level 6 -quality 10 '
          '-loop 0 -preset picture -an -vsync 0 '
          '-y "$outputPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        final size = await File(outputPath).length();
        debugPrint('WhatsApp: Re-encoded with reduced fps -> ${size ~/ 1024}KB');
        success = size <= maxKB * 1024;
      }
    }

    // Cleanup temp frames
    if (await tempDir.exists()) await tempDir.delete(recursive: true);

    return success;
  }

  /// Convert a static image to single-frame "animated" WebP for use in animated packs
  /// WhatsApp requires ALL stickers in an animated pack to be animated WebP format
  Future<void> _convertStaticToAnimatedWebp(String inputPath, String outputPath, int targetSize, int maxKB) async {
    final bytes = await File(inputPath).readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) throw Exception('Resim acilamadi: $inputPath');

    // Scale and pad to targetSize x targetSize
    if (image.width > targetSize || image.height > targetSize || image.width != image.height) {
      final scale = targetSize / (image.width > image.height ? image.width : image.height);
      final newW = (image.width * scale).round().clamp(1, targetSize);
      final newH = (image.height * scale).round().clamp(1, targetSize);
      image = img.copyResize(image, width: newW, height: newH, interpolation: img.Interpolation.linear);
    }
    if (image.width != targetSize || image.height != targetSize) {
      final padded = img.Image(width: targetSize, height: targetSize, numChannels: 4);
      img.fill(padded, color: img.ColorRgba8(0, 0, 0, 0));
      final offsetX = (targetSize - image.width) ~/ 2;
      final offsetY = (targetSize - image.height) ~/ 2;
      img.compositeImage(padded, image, dstX: offsetX, dstY: offsetY);
      image = padded;
    }

    // Save as temp PNGs — duplicate frame 3 times so FFmpeg creates real animated WebP
    // A single frame might not get the VP8X animation flag set
    final tempDir = Directory('${outputPath}_static_frames');
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
    await tempDir.create(recursive: true);
    final pngBytes = img.encodePng(image);
    for (int f = 0; f < 3; f++) {
      await File('${tempDir.path}/frame_${f.toString().padLeft(4, '0')}.png').writeAsBytes(pngBytes);
    }

    // Encode as animated WebP via FFmpeg libwebp (3 frames at 1fps = 3 seconds)
    final maxBytes = maxKB * 1000;
    bool success = false;
    for (int quality = 80; quality >= 10; quality -= 20) {
      final command =
          '-framerate 1 -i "${tempDir.path}/frame_%04d.png" '
          '-vcodec libwebp -lossless 0 -compression_level 4 -quality $quality '
          '-loop 0 -preset picture -an -vsync 0 '
          '-y "$outputPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode) && await File(outputPath).exists()) {
        final size = await File(outputPath).length();
        debugPrint('WhatsApp: Static→AnimatedWebP q=$quality -> ${size} bytes');
        if (size <= maxBytes) {
          success = true;
          break;
        }
      } else {
        final logs = await session.getLogsAsString();
        debugPrint('WhatsApp: Static→AnimatedWebP error: $logs');
      }
    }

    // Cleanup
    if (await tempDir.exists()) await tempDir.delete(recursive: true);

    if (!success) {
      throw Exception('Statik resim animasyonlu WebP formatina donusturulemedi');
    }
  }

  /// Convert animated content to animated WebP for WhatsApp
  Future<void> _convertAnimatedToWebp(String inputPath, String outputPath, int targetSize, int maxKB, {int? trimStartMs, int? trimEndMs}) async {
    final ext = inputPath.split('.').last.toLowerCase();
    final isWebp = ext == 'webp' || await _isWebpFile(inputPath);

    // Use strict byte limit (500000 bytes, not 500*1024=512000)
    final maxBytes = maxKB * 1000;

    // Strategy 1: Source is already animated WebP
    if (isWebp) {
      final fileSize = await File(inputPath).length();

      // Check pixel dimensions — WhatsApp requires exactly targetSize x targetSize
      bool needsResize = false;
      try {
        final bytes = await File(inputPath).readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final w = decoded.width;
          final h = decoded.height;
          debugPrint('WhatsApp: Source is animated WebP (${fileSize} bytes, ${fileSize ~/ 1024}KB, ${w}x${h})');
          needsResize = w != targetSize || h != targetSize;
          if (needsResize) {
            debugPrint('WhatsApp: Dimensions ${w}x${h} != ${targetSize}x${targetSize}, must re-encode');
          }
        } else {
          debugPrint('WhatsApp: Source is animated WebP (${fileSize} bytes, ${fileSize ~/ 1024}KB, could not decode dimensions)');
        }
      } catch (e) {
        debugPrint('WhatsApp: Could not check dimensions: $e');
      }

      // If under size limit AND correct dimensions, copy directly
      if (fileSize <= maxBytes && !needsResize) {
        await File(inputPath).copy(outputPath);
        final isAnimOut = await _isFileAnimated(outputPath);
        debugPrint('WhatsApp: Copied animated WebP directly (${fileSize} bytes, verified animated=$isAnimOut)');
        return;
      }

      // Re-encode: either too large or wrong dimensions
      final reason = needsResize ? 'wrong dimensions' : 'too large (${fileSize} bytes > $maxBytes)';
      debugPrint('WhatsApp: Re-encoding animated WebP ($reason)...');
      final success = await _reencodeViaFrameExtraction(inputPath, outputPath, targetSize, maxBytes ~/ 1000);
      if (success) {
        final isAnimOut = await _isFileAnimated(outputPath);
        debugPrint('WhatsApp: Re-encoded animated WebP verified animated=$isAnimOut');
        return;
      }

      throw Exception('Animasyonlu WebP donusturulemedi (${fileSize ~/ 1024}KB)');
    }

    // Strategy 2: GIF — try FFmpeg direct first, if fails use frame extraction
    if (ext == 'gif') {
      // Try FFmpeg direct (GIF → animated WebP)
      final startSec = (trimStartMs ?? 0) / 1000.0;
      final durationArg = trimEndMs != null
          ? '-t ${((trimEndMs - (trimStartMs ?? 0)) / 1000.0).clamp(0.1, 7.0)}'
          : '-t 7';

      for (int quality = 70; quality >= 10; quality -= 20) {
        final command =
            '-ss $startSec -i "$inputPath" $durationArg '
            '-vf "scale=$targetSize:$targetSize:force_original_aspect_ratio=decrease,'
            'pad=$targetSize:$targetSize:(ow-iw)/2:(oh-ih)/2:color=0x00000000@0" '
            '-vcodec libwebp -lossless 0 -compression_level 4 -quality $quality '
            '-loop 0 -preset picture -an -vsync 0 '
            '-y "$outputPath"';

        final session = await FFmpegKit.execute(command);
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          final size = await File(outputPath).length();
          debugPrint('WhatsApp: GIF→WebP q=$quality -> ${size} bytes (${size ~/ 1024}KB)');
          if (size <= maxBytes) return;
        }
      }

      // FFmpeg failed or too large — try frame extraction
      final success = await _reencodeViaFrameExtraction(inputPath, outputPath, targetSize, maxBytes ~/ 1000);
      if (success) return;

      throw Exception('GIF animasyonlu WebP\'ye donusturulemedi');
    }

    // Strategy 3: Video (MP4, MOV, etc.) → FFmpeg + libwebp
    final startSec = (trimStartMs ?? 0) / 1000.0;
    final durationArg = trimEndMs != null
        ? '-t ${((trimEndMs - (trimStartMs ?? 0)) / 1000.0).clamp(0.1, 7.0)}'
        : '-t 7';

    for (int quality = 70; quality >= 10; quality -= 20) {
      final command =
          '-ss $startSec -i "$inputPath" $durationArg '
          '-vf "scale=$targetSize:$targetSize:force_original_aspect_ratio=decrease,'
          'pad=$targetSize:$targetSize:(ow-iw)/2:(oh-ih)/2:color=0x00000000@0" '
          '-vcodec libwebp -lossless 0 -compression_level 4 -quality $quality '
          '-loop 0 -preset picture -an -vsync 0 '
          '-y "$outputPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        final size = await File(outputPath).length();
        debugPrint('WhatsApp: Video→WebP q=$quality -> ${size} bytes (${size ~/ 1024}KB)');
        if (size <= maxBytes) return;
      } else {
        final logs = await session.getLogsAsString();
        debugPrint('WhatsApp: FFmpeg video error: $logs');
      }
    }

    throw Exception('Video animasyonlu WebP\'ye donusturulemedi');
  }

  /// Prepare sticker pack files and send to WhatsApp via Content Provider
  Future<void> exportPack({
    required StickerPack pack,
    required List<Sticker> stickers,
    void Function(int current, int total, String status)? onProgress,
  }) async {
    if (stickers.length < StickerConstants.whatsappMinStickersPerPack) {
      throw Exception(
        'WhatsApp icin en az ${StickerConstants.whatsappMinStickersPerPack} sticker gerekli '
        '(su an ${stickers.length} tane var)',
      );
    }

    if (stickers.length > StickerConstants.whatsappMaxStickersPerPack) {
      throw Exception(
        'WhatsApp icin en fazla ${StickerConstants.whatsappMaxStickersPerPack} sticker olabilir',
      );
    }

    final filesDir = await _getFilesDir();
    final packDir = Directory('$filesDir/sticker_packs/${pack.uuid}');

    if (await packDir.exists()) {
      await packDir.delete(recursive: true);
    }
    await packDir.create(recursive: true);

    // Detect animated stickers from actual file content
    bool hasAnimated = false;
    for (final s in stickers) {
      if (s.isAnimated || await _isFileAnimated(s.sourcePath)) {
        hasAnimated = true;
        break;
      }
    }
    debugPrint('WhatsApp: Pack hasAnimated=$hasAnimated (${stickers.length} stickers)');

    // Write config file — version uses timestamp so WhatsApp picks up updates
    final version = DateTime.now().millisecondsSinceEpoch.toString();
    await File('${packDir.path}/config.txt').writeAsString(
      '${pack.name}\n${pack.author.isEmpty ? "Sticcker" : pack.author}\n${hasAnimated ? "1" : "0"}\n$version',
    );

    // Convert each sticker
    for (int i = 0; i < stickers.length; i++) {
      final sticker = stickers[i];
      final destPath = '${packDir.path}/sticker_$i.webp';

      onProgress?.call(i, stickers.length, 'Donusturuluyor: ${i + 1}/${stickers.length}');

      // For animated stickers, ALWAYS use original sourcePath (processedPath may be static)
      // Also check the actual file content to detect animation
      final isAnimatedByModel = sticker.isAnimated;
      final isAnimatedBySource = await _isFileAnimated(sticker.sourcePath);
      final isAnimated = isAnimatedByModel || isAnimatedBySource;

      // Use original source for animated, processed for static
      final sourcePath = isAnimated ? sticker.sourcePath : (sticker.processedPath ?? sticker.sourcePath);

      debugPrint('WhatsApp: Sticker $i: modelAnimated=$isAnimatedByModel, sourceAnimated=$isAnimatedBySource, '
          'using=${isAnimated ? "ANIMATED" : "STATIC"} path=$sourcePath');

      if (isAnimated) {
        // Animated sticker → animated WebP via FFmpeg libwebp
        await _convertAnimatedToWebp(
          sourcePath,
          destPath,
          StickerConstants.whatsappStickerSize,
          StickerConstants.whatsappMaxAnimatedSizeKB,
          trimStartMs: sticker.trimStartMs,
          trimEndMs: sticker.trimEndMs,
        );
      } else if (hasAnimated) {
        // Static sticker in animated pack → single-frame animated WebP
        // WhatsApp requires ALL stickers in animated pack to be animated format
        debugPrint('WhatsApp: Converting static sticker $i to animated format (animated pack)');
        await _convertStaticToAnimatedWebp(
          sourcePath,
          destPath,
          StickerConstants.whatsappStickerSize,
          StickerConstants.whatsappMaxAnimatedSizeKB,
        );
      } else {
        // Static sticker in static pack → static WebP via flutter_image_compress
        await _convertStaticToWebp(
          sourcePath,
          destPath,
          StickerConstants.whatsappStickerSize,
          StickerConstants.whatsappMaxStaticSizeKB,
        );
      }
    }

    // Log final sticker info for debugging
    for (int i = 0; i < stickers.length; i++) {
      final f = File('${packDir.path}/sticker_$i.webp');
      if (await f.exists()) {
        final size = await f.length();
        final anim = await _isFileAnimated(f.path);
        debugPrint('WhatsApp: FINAL sticker_$i.webp: ${size} bytes, animated=$anim');
      }
    }

    // Create tray icon (96x96 WebP, max 50KB) — always static
    onProgress?.call(stickers.length, stickers.length, 'Tray icon olusturuluyor...');
    final firstStickerPath = stickers.first.processedPath ?? stickers.first.sourcePath;
    await _convertStaticToWebp(
      firstStickerPath,
      '${packDir.path}/tray.webp',
      StickerConstants.whatsappTrayIconSize,
      50,
    );

    // Trigger WhatsApp intent
    try {
      await _channel.invokeMethod('addStickerPack', {
        'identifier': pack.uuid,
        'name': pack.name,
      });
    } on PlatformException catch (e) {
      debugPrint('WhatsApp export error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'WHATSAPP_NOT_FOUND':
          throw Exception('WhatsApp yuklu degil');
        case 'WHATSAPP_REJECTED':
          throw Exception(e.message ?? 'WhatsApp sticker paketini reddetti');
        default:
          throw Exception('WhatsApp hatasi: ${e.message}');
      }
    } on MissingPluginException {
      throw Exception('WhatsApp entegrasyonu sadece Android\'de calisiyor');
    }
  }
}
