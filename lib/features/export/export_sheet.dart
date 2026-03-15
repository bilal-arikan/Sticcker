import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/sticker_constants.dart';
import '../../core/providers.dart';
import '../../data/services/telegram_service.dart';

class ExportSheet extends ConsumerStatefulWidget {
  final int packId;
  final ExportPlatform platform;

  const ExportSheet({super.key, required this.packId, required this.platform});

  @override
  ConsumerState<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends ConsumerState<ExportSheet> {
  bool _isExporting = false;
  String _statusMessage = '';
  double _progress = 0;
  String? _errorMessage;

  // Telegram-specific
  final _setNameController = TextEditingController();
  final _userIdController = TextEditingController();

  @override
  void dispose() {
    _setNameController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context)!;
    final isWhatsApp = widget.platform == ExportPlatform.whatsapp;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isWhatsApp ? Icons.chat_bubble : Icons.send,
                color: isWhatsApp ? Colors.green : Colors.blue,
              ),
              const SizedBox(width: 12),
              Text(
                isWhatsApp ? l.exportToWhatsApp : l.exportToTelegram,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!isWhatsApp) ...[
            TextField(
              controller: _setNameController,
              decoration: InputDecoration(
                labelText: l.stickerSetName,
                hintText: 'my_sticker_set',
                helperText: l.stickerSetNameHelper,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: l.telegramUserId,
                hintText: '123456789',
                helperText: l.telegramUserIdHelper,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
          ],

          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l.error,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (_isExporting) ...[
            LinearProgressIndicator(value: _progress > 0 ? _progress : null),
            const SizedBox(height: 8),
            Text(_statusMessage, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
          ],

          if (!_isExporting)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _export,
                icon: const Icon(Icons.upload),
                label: Text(isWhatsApp ? l.sendToWhatsApp : l.sendToTelegram),
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _export() async {
    setState(() {
      _errorMessage = null;
    });

    if (widget.platform == ExportPlatform.whatsapp) {
      await _exportToWhatsApp();
    } else {
      await _exportToTelegram();
    }
  }

  Future<void> _exportToWhatsApp() async {
    final l = S.of(context)!;
    setState(() {
      _isExporting = true;
      _statusMessage = l.preparingStickers;
      _errorMessage = null;
    });

    try {
      final stickers = await ref.read(stickerRepositoryProvider).getStickersForPack(widget.packId);
      final pack = await ref.read(packRepositoryProvider).getPackById(widget.packId);

      if (pack == null) throw Exception(l.packNotFound);

      final whatsappService = ref.read(whatsappServiceProvider);
      await whatsappService.exportPack(
        pack: pack,
        stickers: stickers,
        onProgress: (current, total, status) {
          if (mounted) {
            setState(() {
              _progress = current / total;
              final fileName = current < stickers.length
                  ? stickers[current].sourcePath.split('/').last.split('\\').last
                  : '';
              _statusMessage = fileName.isNotEmpty
                  ? l.convertingDetail(current + 1, total, fileName)
                  : status;
            });
          }
        },
      );

      // Update sync status
      pack.isSyncedToWhatsApp = true;
      await ref.read(packRepositoryProvider).updatePack(pack);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.sentToWhatsApp)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _exportToTelegram() async {
    final l = S.of(context)!;
    final setName = _setNameController.text.trim();
    final userIdText = _userIdController.text.trim();

    if (setName.isEmpty || userIdText.isEmpty) {
      setState(() => _errorMessage = l.setNameAndUserIdRequired);
      return;
    }

    final userId = int.tryParse(userIdText);
    if (userId == null) {
      setState(() => _errorMessage = l.invalidUserId);
      return;
    }

    final telegramService = ref.read(telegramServiceProvider);
    if (!telegramService.isConfigured) {
      setState(() => _errorMessage = l.telegramBotTokenNotConfigured);
      return;
    }

    setState(() {
      _isExporting = true;
      _statusMessage = l.preparingStickers;
      _errorMessage = null;
    });

    try {
      final stickers = await ref.read(stickerRepositoryProvider).getStickersForPack(widget.packId);
      final processor = await ref.read(mediaProcessorProvider.future);

      final stickerInputs = <StickerInput>[];

      for (int i = 0; i < stickers.length; i++) {
        if (!mounted) return;
        final fileName = stickers[i].sourcePath.split('/').last.split('\\').last;
        setState(() {
          _progress = i / stickers.length;
          _statusMessage = l.convertingDetail(i + 1, stickers.length, fileName);
        });

        String filePath;
        if (stickers[i].isAnimated) {
          filePath = await processor.processVideoToWebm(
            stickers[i].sourcePath,
            trimStartMs: stickers[i].trimStartMs,
            trimEndMs: stickers[i].trimEndMs,
          );
        } else {
          filePath = stickers[i].processedPath ??
              await processor.processImage(stickers[i].sourcePath);
        }

        stickerInputs.add(StickerInput(
          filePath: filePath,
          emoji: stickers[i].emoji ?? '😀',
          type: stickers[i].stickerType,
        ));
      }

      if (!mounted) return;
      setState(() => _statusMessage = l.sendingToTelegram);

      await telegramService.createStickerSet(
        userId: userId,
        name: '${setName}_by_sticcker_bot',
        title: setName,
        stickers: stickerInputs,
      );

      // Update pack sync status
      final pack = await ref.read(packRepositoryProvider).getPackById(widget.packId);
      if (pack != null) {
        pack.isSyncedToTelegram = true;
        pack.telegramSetName = setName;
        await ref.read(packRepositoryProvider).updatePack(pack);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.sentToTelegram)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }
}
