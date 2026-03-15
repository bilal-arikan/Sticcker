import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/sticker_constants.dart';
import '../../core/providers.dart';
import '../../data/models/sticker.dart';
import '../../data/models/sticker_pack.dart';
import '../../data/services/media_processor.dart';
import '../sticker_editor/sticker_editor_screen.dart';
import '../export/export_sheet.dart';
import '../../core/utils/error_dialog.dart';

class PackEditorScreen extends ConsumerStatefulWidget {
  final int packId;

  const PackEditorScreen({super.key, required this.packId});

  @override
  ConsumerState<PackEditorScreen> createState() => _PackEditorScreenState();
}

class _PackEditorScreenState extends ConsumerState<PackEditorScreen> {
  bool _isProcessing = false;
  double _progress = 0;
  String _packName = '';

  @override
  void initState() {
    super.initState();
    _loadPackName();
  }

  Future<void> _loadPackName() async {
    final pack = await ref.read(packRepositoryProvider).getPackById(widget.packId);
    if (mounted && pack != null) {
      setState(() => _packName = pack.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context)!;
    final stickersAsync = ref.watch(packStickersProvider(widget.packId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_packName.isEmpty ? l.pack : _packName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editPackInfo(context, ref),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, context, ref),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'whatsapp', child: Text(l.exportToWhatsApp)),
              PopupMenuItem(value: 'telegram', child: Text(l.exportToTelegram)),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Text(l.deletePack, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          stickersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text(l.errorGeneric(err.toString()))),
            data: (stickers) => stickers.isEmpty
                ? _buildEmptyState(context, l)
                : _buildStickerGrid(context, ref, stickers),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(value: _progress > 0 ? _progress : null),
                        const SizedBox(height: 16),
                        Text(l.processingProgress((_progress * 100).toInt())),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'gallery',
            onPressed: () => _pickFromGallery(context, ref),
            child: const Icon(Icons.photo_library_outlined),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'file',
            onPressed: () => _pickFromFiles(context, ref),
            child: const Icon(Icons.folder_open_outlined),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'camera',
            onPressed: () => _pickFromCamera(context, ref),
            child: const Icon(Icons.camera_alt_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, S l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l.addSticker,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l.addStickerSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerGrid(BuildContext context, WidgetRef ref, List<Sticker> stickers) {
    final columns = ref.watch(gridColumnsProvider);
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        final sticker = stickers[index];
        return _StickerTile(
          sticker: sticker,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StickerEditorScreen(stickerId: sticker.id!),
              ),
            );
            ref.invalidate(packStickersProvider(widget.packId));
          },
          onDelete: () => _deleteSticker(ref, sticker),
        );
      },
    );
  }

  Future<void> _pickFromGallery(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isNotEmpty) {
      await _processFiles(ref, files.map((f) => f.path).toList());
    }
  }

  Future<void> _pickFromCamera(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      await _processFiles(ref, [file.path]);
    }
  }

  Future<void> _pickFromFiles(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: StickerConstants.allSupportedFormats,
    );
    if (result != null && result.files.isNotEmpty) {
      final paths = result.files
          .where((f) => f.path != null)
          .map((f) => f.path!)
          .toList();
      await _processFiles(ref, paths);
    }
  }

  Future<void> _processFiles(WidgetRef ref, List<String> paths) async {
    final l = S.of(context)!;

    // Check platform limit (use Telegram's 120 as max since it's the highest)
    final currentStickers = await ref.read(stickerRepositoryProvider)
        .getStickersForPack(widget.packId);
    final currentCount = currentStickers.length;
    final maxLimit = StickerConstants.telegramMaxStickersPerPack;
    final available = maxLimit - currentCount;

    if (available <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.stickerLimitExceeded(maxLimit, paths.length))),
        );
      }
      return;
    }

    int skipped = 0;
    if (paths.length > available) {
      skipped = paths.length - available;
      paths = paths.sublist(0, available);
    }

    setState(() {
      _isProcessing = true;
      _progress = 0;
    });

    final List<MapEntry<String, String>> failedFiles = [];

    try {
      final processor = await ref.read(mediaProcessorProvider.future);
      final stickerRepo = ref.read(stickerRepositoryProvider);
      final packRepo = ref.read(packRepositoryProvider);

      await for (final progress in processor.batchProcess(paths, packId: widget.packId)) {
        if (!mounted) break;
        setState(() => _progress = progress.progress);

        if (progress.status == ProcessingStatus.done && progress.processedPath != null) {
          final mediaType = processor.detectMediaType(progress.currentFile);
          // Copy source to permanent location so it survives cache cleanup
          final cache = await ref.read(stickerCacheProvider.future);
          String permanentSource;
          try {
            permanentSource = await cache.preserveSource(progress.currentFile);
          } catch (_) {
            permanentSource = progress.currentFile;
          }
          final sticker = await stickerRepo.createSticker(
            sourcePath: permanentSource,
            mediaType: mediaType,
            packId: widget.packId,
          );
          sticker.processedPath = progress.processedPath;
          await stickerRepo.updateSticker(sticker);
        } else if (progress.status == ProcessingStatus.error) {
          final fileName = progress.currentFile.split('/').last.split('\\').last;
          failedFiles.add(MapEntry(fileName, progress.error ?? 'Unknown error'));
        }
      }

      await packRepo.updateStickerCount(widget.packId);
      ref.invalidate(packStickersProvider(widget.packId));
      ref.invalidate(allPacksProvider);

      if (mounted) {
        if (skipped > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.stickerLimitExceeded(maxLimit, skipped))),
          );
        }
        if (failedFiles.isNotEmpty) {
          _showFailedFilesDialog(context, l, failedFiles);
        }
      }
    } catch (e, st) {
      if (mounted) {
        showErrorDialog(context, e, st);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _deleteSticker(WidgetRef ref, Sticker sticker) async {
    final l = S.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteSticker),
        content: Text(l.deleteStickerConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(stickerRepositoryProvider).deleteSticker(sticker.id!);
      await ref.read(packRepositoryProvider).updateStickerCount(widget.packId);
      ref.invalidate(packStickersProvider(widget.packId));
      ref.invalidate(allPacksProvider);
    }
  }

  void _handleMenuAction(String value, BuildContext context, WidgetRef ref) {
    switch (value) {
      case 'whatsapp':
      case 'telegram':
        showModalBottomSheet(
          context: context,
          builder: (_) => ExportSheet(
            packId: widget.packId,
            platform: value == 'whatsapp' ? ExportPlatform.whatsapp : ExportPlatform.telegram,
          ),
        );
        break;
      case 'delete':
        _deletePack(context, ref);
        break;
    }
  }

  void _showFailedFilesDialog(BuildContext context, S l, List<MapEntry<String, String>> failedFiles) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.failedFiles),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: failedFiles.length,
            itemBuilder: (_, i) {
              final entry = failedFiles[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  l.failedFileReason(entry.key, entry.value),
                  style: const TextStyle(fontSize: 13),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _editPackInfo(BuildContext context, WidgetRef ref) async {
    final l = S.of(context)!;
    final pack = await ref.read(packRepositoryProvider).getPackById(widget.packId);
    if (pack == null) return;

    final nameController = TextEditingController(text: pack.name);
    final authorController = TextEditingController(text: pack.author);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.editPack),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: l.packName)),
            const SizedBox(height: 12),
            TextField(controller: authorController, decoration: InputDecoration(labelText: l.author)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.save)),
        ],
      ),
    );

    if (result == true) {
      pack.name = nameController.text.trim();
      pack.author = authorController.text.trim();
      await ref.read(packRepositoryProvider).updatePack(pack);
      ref.invalidate(allPacksProvider);
      setState(() => _packName = pack.name);
    }
  }

  Future<void> _deletePack(BuildContext context, WidgetRef ref) async {
    final l = S.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deletePack),
        content: Text(l.deletePackConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(packRepositoryProvider).deletePack(widget.packId);
      ref.invalidate(allPacksProvider);
      if (mounted) Navigator.pop(context);
    }
  }
}

class _StickerTile extends StatelessWidget {
  final Sticker sticker;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StickerTile({
    required this.sticker,
    required this.onTap,
    required this.onDelete,
  });

  String get _fileExtension {
    final path = sticker.processedPath ?? sticker.sourcePath;
    final ext = path.split('.').last.toUpperCase();
    return ext;
  }

  String get _fileSize {
    try {
      final path = sticker.processedPath ?? sticker.sourcePath;
      final size = File(path).lengthSync();
      if (size < 1024) return '$size B';
      if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(0)} KB';
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            sticker.processedPath != null
                ? Image.file(
                    File(sticker.processedPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                  )
                : _buildPlaceholder(context),
            Positioned(
              left: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _fileSize,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _fileExtension,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          sticker.isAnimated ? Icons.gif_box_outlined : Icons.image_outlined,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
