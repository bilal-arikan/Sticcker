import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../core/constants/sticker_constants.dart';
import '../../core/providers.dart';
import '../../data/models/sticker.dart';
import '../../core/utils/error_dialog.dart';

class StickerEditorScreen extends ConsumerStatefulWidget {
  final int stickerId;

  const StickerEditorScreen({super.key, required this.stickerId});

  @override
  ConsumerState<StickerEditorScreen> createState() => _StickerEditorScreenState();
}

class _StickerEditorScreenState extends ConsumerState<StickerEditorScreen> {
  Sticker? _sticker;
  bool _isProcessing = false;
  String? _previewPath; // Static image for display (first frame for animated)

  // Video trim state
  double _trimStart = 0;
  double _trimEnd = 3000; // 3 seconds in ms
  double _videoDuration = 0;

  // For animated media: the rotated animated file path
  String? _animatedSourcePath;
  // Crop state for animated media (relative to post-rotation frame dimensions)
  double? _cropX, _cropY, _cropW, _cropH;
  // Rotation count: 0=none, 1=90°, 2=180°, 3=270°
  int _rotationCount = 0;

  /// Check if source could be animated (video/gif OR animated WebP/GIF file)
  bool get _isAnimatedMedia {
    if (_sticker == null) return false;
    if (_sticker!.isAnimated) return true;
    final ext = _sticker!.sourcePath.split('.').last.toLowerCase();
    return ext == 'webp' || ext == 'gif';
  }

  /// Get the original source file (always use original for animated, never re-process animated WebP)
  Future<String?> _getOriginalSource() async {
    if (_sticker == null) return null;
    if (await File(_sticker!.sourcePath).exists()) return _sticker!.sourcePath;
    if (_sticker!.processedPath != null && await File(_sticker!.processedPath!).exists()) {
      return _sticker!.processedPath;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadSticker();
  }

  Future<void> _loadSticker() async {
    final sticker = await ref.read(stickerRepositoryProvider).getStickerById(widget.stickerId);
    if (sticker != null && mounted) {
      // Ensure source file exists — if not, try to preserve a copy
      if (!await File(sticker.sourcePath).exists()) {
        debugPrint('[Editor] sourcePath missing: ${sticker.sourcePath}');
        // If processedPath exists, copy it as the new source
        if (sticker.processedPath != null && await File(sticker.processedPath!).exists()) {
          try {
            final cache = await ref.read(stickerCacheProvider.future);
            final permanentSource = await cache.preserveSource(sticker.processedPath!);
            sticker.sourcePath = permanentSource;
            await ref.read(stickerRepositoryProvider).updateSticker(sticker);
            debugPrint('[Editor] sourcePath updated to: $permanentSource');
          } catch (e) {
            debugPrint('[Editor] Failed to preserve source: $e');
          }
        }
      }
      setState(() {
        _sticker = sticker;
        _previewPath = sticker.processedPath ?? sticker.sourcePath;
      });
      if (sticker.trimStartMs != null) _trimStart = sticker.trimStartMs!.toDouble();
      if (sticker.trimEndMs != null) _trimEnd = sticker.trimEndMs!.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context)!;

    if (_sticker == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.editSticker),
        actions: [
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveAndProcess,
            ),
        ],
      ),
      body: Column(
        children: [
          // Preview
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _previewPath != null
                    ? Image.file(
                        File(_previewPath!),
                        key: ValueKey(_previewPath),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 48),
                        ),
                      )
                    : const Center(child: Icon(Icons.image, size: 48)),
              ),
            ),
          ),

          // Video trim controls
          if (_isAnimatedMedia) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.videoDuration(_formatDuration(_trimStart.toInt()), _formatDuration(_trimEnd.toInt())),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: RangeValues(_trimStart, _trimEnd),
                    min: 0,
                    max: _videoDuration > 0 ? _videoDuration : 10000,
                    divisions: 100,
                    labels: RangeLabels(
                      _formatDuration(_trimStart.toInt()),
                      _formatDuration(_trimEnd.toInt()),
                    ),
                    onChanged: (values) {
                      final maxDuration = StickerConstants.telegramMaxVideoDurationSec * 1000;
                      if ((values.end - values.start) <= maxDuration) {
                        setState(() {
                          _trimStart = values.start;
                          _trimEnd = values.end;
                        });
                      }
                    },
                  ),
                  Text(
                    l.maxDurationTelegram(StickerConstants.telegramMaxVideoDurationSec),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Tool bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ToolButton(
                  icon: Icons.crop,
                  label: l.crop,
                  onTap: () => _cropImage(),
                ),
                _ToolButton(
                  icon: Icons.rotate_right,
                  label: l.rotate,
                  onTap: () => _rotateImage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int ms) {
    final seconds = ms ~/ 1000;
    final milliseconds = (ms % 1000) ~/ 100;
    return '$seconds.${milliseconds}s';
  }

  Future<void> _cropImage() async {
    if (_sticker == null || _isProcessing) return;
    final l = S.of(context)!;

    setState(() => _isProcessing = true);
    try {
      String? framePath;

      if (_isAnimatedMedia) {
        // Use current animated source (may be rotated) or original
        final source = _animatedSourcePath ?? await _getOriginalSource();
        if (source == null) {
          debugPrint('[Editor] No source file found for crop');
          return;
        }

        final processor = await ref.read(mediaProcessorProvider.future);
        try {
          framePath = await processor.extractFirstFrame(source);
        } catch (e) {
          debugPrint('[Editor] extractFirstFrame failed: $e');
          // Fallback: use preview if it's a static image
          if (_previewPath != null && await File(_previewPath!).exists()) {
            framePath = _previewPath;
          } else {
            return;
          }
        }
      } else {
        // Static image: use preview path if it exists, otherwise source
        if (_previewPath != null && await File(_previewPath!).exists()) {
          framePath = _previewPath;
        } else if (await File(_sticker!.sourcePath).exists()) {
          framePath = _sticker!.sourcePath;
        } else if (_sticker!.processedPath != null && await File(_sticker!.processedPath!).exists()) {
          framePath = _sticker!.processedPath;
        }
      }

      if (framePath == null || !await File(framePath).exists()) {
        debugPrint('[Editor] No valid file found for crop');
        return;
      }

      // Read frame dimensions before crop (these are post-rotation dimensions)
      final originalBytes = await File(framePath).readAsBytes();
      final decodedOriginal = await decodeImageFromList(originalBytes);
      final frameW = decodedOriginal.width;
      final frameH = decodedOriginal.height;

      if (!mounted) return;
      setState(() => _isProcessing = false);

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: framePath,
        compressFormat: ImageCompressFormat.png,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: l.cropSticker,
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: l.cropSticker),
        ],
      );

      if (croppedFile != null && mounted) {
        if (_isAnimatedMedia) {
          // Read cropped dimensions to compute crop coordinates
          final croppedBytes = await File(croppedFile.path).readAsBytes();
          final decodedCropped = await decodeImageFromList(croppedBytes);
          final cropW = decodedCropped.width.toDouble();
          final cropH = decodedCropped.height.toDouble();
          // Center assumption for crop position (relative to rotated frame)
          final cropX = (frameW - cropW) / 2;
          final cropY = (frameH - cropH) / 2;

          debugPrint('[Editor] Crop coords (post-rotation): x=$cropX y=$cropY w=$cropW h=$cropH (frame: ${frameW}x$frameH)');

          setState(() {
            _previewPath = croppedFile.path;
            _cropX = cropX.clamp(0, frameW.toDouble());
            _cropY = cropY.clamp(0, frameH.toDouble());
            _cropW = cropW;
            _cropH = cropH;
          });
        } else {
          setState(() => _previewPath = croppedFile.path);
        }
      }
    } catch (e, st) {
      if (mounted) showErrorDialog(context, e, st);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _rotateImage() async {
    if (_sticker == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final processor = await ref.read(mediaProcessorProvider.future);

      if (_isAnimatedMedia) {
        // ALWAYS use original source for rotation — FFmpeg cannot read animated WebP output
        final source = await _getOriginalSource();
        if (source == null) {
          debugPrint('[Editor] No source file found for rotate');
          return;
        }

        final newRotation = (_rotationCount + 1) % 4;

        if (newRotation == 0) {
          // Back to original orientation — no rotation needed
          if (mounted) {
            setState(() {
              _animatedSourcePath = null;
              _previewPath = _sticker!.processedPath ?? _sticker!.sourcePath;
              _rotationCount = 0;
              _cropX = null;
              _cropY = null;
              _cropW = null;
              _cropH = null;
            });
          }
          debugPrint('[Editor] Rotation reset to 0°');
        } else {
          // Rotate from ORIGINAL source with cumulative rotation count
          final rotatedPath = await processor.rotateImage(
            source,
            preserveAnimation: true,
            rotationCount: newRotation,
          );

          // Reset crop when rotating (coordinates change)
          if (mounted) {
            setState(() {
              _animatedSourcePath = rotatedPath;
              _previewPath = rotatedPath; // Show animated preview
              _rotationCount = newRotation;
              _cropX = null;
              _cropY = null;
              _cropW = null;
              _cropH = null;
            });
          }
          debugPrint('[Editor] Rotation set to ${newRotation * 90}°, animated file: $rotatedPath');
        }
      } else {
        // Static image: rotate the actual file
        String source = _sticker!.sourcePath;
        if (_previewPath != null && await File(_previewPath!).exists()) {
          source = _previewPath!;
        } else if (_sticker!.processedPath != null && await File(_sticker!.processedPath!).exists()) {
          source = _sticker!.processedPath!;
        }

        final rotatedPath = await processor.rotateImage(source);
        if (mounted) setState(() => _previewPath = rotatedPath);
      }
    } catch (e, st) {
      if (mounted) showErrorDialog(context, e, st);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveAndProcess() async {
    if (_sticker == null || _isProcessing) return;
    final l = S.of(context)!;

    setState(() => _isProcessing = true);
    try {
      final processor = await ref.read(mediaProcessorProvider.future);
      final stickerRepo = ref.read(stickerRepositoryProvider);

      String processedPath;
      if (_isAnimatedMedia) {
        if (_sticker!.isAnimated) {
          _sticker!.trimStartMs = _trimStart.toInt();
          _sticker!.trimEndMs = _trimEnd.toInt();
        }

        final hasCrop = _cropX != null;
        final hasRotation = _rotationCount > 0;
        final hasEdits = hasCrop || hasRotation;

        // If no edits and already processed, keep existing processedPath
        if (!hasEdits && _sticker!.processedPath != null &&
            await File(_sticker!.processedPath!).exists() &&
            await File(_sticker!.processedPath!).length() > 0) {
          debugPrint('[Editor] No edits, keeping existing processedPath');
          processedPath = _sticker!.processedPath!;
        } else if (hasRotation && !hasCrop && _animatedSourcePath != null &&
            await File(_animatedSourcePath!).exists()) {
          // Rotation only (no crop): use the already-rotated animated file directly
          // FFmpeg cannot read animated WebP as input, so skip processToAnimatedWebp
          debugPrint('[Editor] Save: using rotated animated file directly (no FFmpeg): $_animatedSourcePath');
          processedPath = _animatedSourcePath!;
        } else {
          // Use ORIGINAL source + rotation/crop filters in single pass
          final source = await _getOriginalSource();
          if (source == null) {
            throw Exception('Source file not found');
          }

          debugPrint('[Editor] Save: source=$source, rotation=${_rotationCount * 90}°, crop=($_cropX,$_cropY,$_cropW,$_cropH)');

          processedPath = await processor.processToAnimatedWebp(
            source,
            trimStartMs: _sticker!.isAnimated ? _trimStart.toInt() : null,
            trimEndMs: _sticker!.isAnimated ? _trimEnd.toInt() : null,
            cropX: _cropX,
            cropY: _cropY,
            cropWidth: _cropW,
            cropHeight: _cropH,
            rotationCount: _rotationCount,
          );
        }
      } else {
        // Use edited preview (cropped/rotated) as source, then process to 512x512 webp
        String source;
        if (_previewPath != null && await File(_previewPath!).exists()) {
          source = _previewPath!;
        } else if (_sticker!.processedPath != null && await File(_sticker!.processedPath!).exists()) {
          source = _sticker!.processedPath!;
        } else {
          source = _sticker!.sourcePath;
        }
        processedPath = await processor.processImage(source);
      }

      // Validate output before saving
      final outputFile = File(processedPath);
      if (!await outputFile.exists()) {
        throw Exception('İşlenmiş dosya oluşturulamadı');
      }
      final outputSize = await outputFile.length();
      debugPrint('[Editor] Processed file: $processedPath ($outputSize bytes)');
      if (outputSize == 0) {
        await outputFile.delete().catchError((_) => outputFile);
        throw Exception('İşlenmiş dosya boş (0 bayt)');
      }

      _sticker!.processedPath = processedPath;
      if (_sticker!.emoji == null) _sticker!.emoji = '😀';
      await stickerRepo.updateSticker(_sticker!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.stickerSaved)),
        );
        Navigator.pop(context);
      }
    } catch (e, st) {
      if (mounted) {
        showErrorDialog(context, e, st);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ToolButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: enabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: enabled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
