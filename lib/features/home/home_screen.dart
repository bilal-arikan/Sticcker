import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers.dart';
import '../../core/constants/sticker_constants.dart';
import '../../data/models/sticker.dart';
import '../../data/models/sticker_pack.dart';
import '../../data/services/telegram_service.dart';
import '../pack_editor/pack_editor_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context)!;
    final packsAsync = ref.watch(allPacksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: l.importFromTelegram,
            onPressed: () => _showTelegramImportDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: packsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(l.errorGeneric(err.toString()))),
        data: (packs) => packs.isEmpty
            ? _buildEmptyState(context, l)
            : _buildPackList(context, ref, packs),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePackDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.newPack),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, S l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_emotions_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l.emptyPacksTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l.emptyPacksSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackList(BuildContext context, WidgetRef ref, List<StickerPack> packs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: packs.length,
      itemBuilder: (context, index) {
        final pack = packs[index];
        return _PackCard(pack: pack);
      },
    );
  }

  Future<void> _showCreatePackDialog(BuildContext context, WidgetRef ref) async {
    final l = S.of(context)!;
    final nameController = TextEditingController();
    final authorController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.newStickerPack),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l.packName,
                hintText: l.packNameHint,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: authorController,
              decoration: InputDecoration(
                labelText: l.author,
                hintText: l.authorHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, {
              'name': nameController.text.trim(),
              'author': authorController.text.trim(),
            }),
            child: Text(l.create),
          ),
        ],
      ),
    );

    if (result != null && result['name']!.isNotEmpty) {
      await ref.read(packRepositoryProvider).createPack(
            name: result['name']!,
            author: result['author']!,
          );
      ref.invalidate(allPacksProvider);
    }
  }

  Future<void> _showTelegramImportDialog(BuildContext context, WidgetRef ref) async {
    final l = S.of(context)!;
    final telegramService = ref.read(telegramServiceProvider);

    if (!telegramService.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.telegramBotTokenRequired)),
      );
      return;
    }

    final setNameController = TextEditingController();

    final setName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.telegramImportTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.telegramImportInfo,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: setNameController,
              decoration: InputDecoration(
                labelText: l.setName,
                hintText: 'Animals_by_BotName',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, setNameController.text.trim()),
            child: Text(l.import_),
          ),
        ],
      ),
    );

    if (setName == null || setName.isEmpty) return;
    if (!context.mounted) return;

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _TelegramImportProgress(
        setName: setName,
        telegramService: telegramService,
        packRepo: ref.read(packRepositoryProvider),
        stickerRepo: ref.read(stickerRepositoryProvider),
        onDone: () {
          Navigator.pop(ctx);
          ref.invalidate(allPacksProvider);
        },
      ),
    );
  }
}

class _PackCard extends ConsumerWidget {
  final StickerPack pack;

  const _PackCard({required this.pack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PackEditorScreen(packId: pack.id!),
            ),
          );
          ref.invalidate(allPacksProvider);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    pack.name.isNotEmpty ? pack.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pack.author.isNotEmpty
                          ? l.stickerCountWithAuthor(pack.stickerCount, pack.author)
                          : l.stickerCountInfo(pack.stickerCount),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pack.isSyncedToWhatsApp)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.check_circle, size: 18, color: Colors.green),
                    ),
                  if (pack.isSyncedToTelegram)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.send, size: 18, color: Colors.blue),
                    ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TelegramImportProgress extends StatefulWidget {
  final String setName;
  final TelegramService telegramService;
  final dynamic packRepo;
  final dynamic stickerRepo;
  final VoidCallback onDone;

  const _TelegramImportProgress({
    required this.setName,
    required this.telegramService,
    required this.packRepo,
    required this.stickerRepo,
    required this.onDone,
  });

  @override
  State<_TelegramImportProgress> createState() => _TelegramImportProgressState();
}

class _TelegramImportProgressState extends State<_TelegramImportProgress> {
  late String _status;
  double _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _status = '';
    _doImport();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_status.isEmpty) {
      _status = S.of(context)!.starting;
    }
  }

  Future<void> _doImport() async {
    // Wait for context to be available
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    final l = S.of(context)!;

    try {
      setState(() => _status = l.downloadingStickerSet);

      final appDir = await getApplicationDocumentsDirectory();
      final saveDir = '${appDir.path}/telegram_import/${widget.setName}';

      final result = await widget.telegramService.importStickerSet(
        widget.setName,
        saveDir,
        onProgress: (current, total) {
          if (mounted) {
            setState(() {
              _progress = total > 0 ? current / total : 0;
              _status = l.downloadingProgress(current, total);
            });
          }
        },
      );

      if (result.stickers.isEmpty) {
        setState(() => _error = l.stickerSetEmptyOrFailed);
        return;
      }

      setState(() => _status = l.creatingPack);

      // Create pack in database
      final pack = await widget.packRepo.createPack(
        name: result.title,
        author: 'Telegram',
      );

      // Add stickers to pack
      for (int i = 0; i < result.stickers.length; i++) {
        final imported = result.stickers[i];

        MediaType mediaType = MediaType.image;
        StickerType stickerType = StickerType.image;
        if (imported.isVideo) {
          mediaType = MediaType.video;
          stickerType = StickerType.video;
        } else if (imported.isAnimated) {
          mediaType = MediaType.gif;
          stickerType = StickerType.animated;
        }

        final sticker = Sticker(
          uuid: const Uuid().v4(),
          sourcePath: imported.localPath,
          mediaType: mediaType,
          stickerType: stickerType,
          emoji: imported.emoji,
          packId: pack.id,
          orderInPack: i,
          createdAt: DateTime.now(),
        );

        await widget.stickerRepo.insertSticker(sticker);
      }

      await widget.packRepo.updateStickerCount(pack.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.importedSuccess(result.title, result.stickers.length))),
        );
        widget.onDone();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context)!;
    return AlertDialog(
      title: Text(l.importingFromTelegram),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null) ...[
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ] else ...[
            LinearProgressIndicator(value: _progress > 0 ? _progress : null),
            const SizedBox(height: 12),
            Text(_status),
          ],
        ],
      ),
      actions: _error != null
          ? [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.close),
              ),
            ]
          : null,
    );
  }
}
