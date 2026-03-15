import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/pack_repository.dart';
import '../data/repositories/sticker_repository.dart';
import '../data/services/media_processor.dart';
import '../data/services/telegram_service.dart';
import '../data/services/whatsapp_service.dart';
import '../data/cache/sticker_cache.dart';
import '../data/models/sticker_pack.dart';
import '../data/models/sticker.dart';

// Repositories
final packRepositoryProvider = Provider((ref) => PackRepository());
final stickerRepositoryProvider = Provider((ref) => StickerRepository());

// Services
final telegramServiceProvider = Provider((ref) => TelegramService());
final whatsappServiceProvider = Provider((ref) => WhatsAppService());

final stickerCacheProvider = FutureProvider((ref) => StickerCache.getInstance());

final mediaProcessorProvider = FutureProvider((ref) async {
  final cache = await ref.read(stickerCacheProvider.future);
  return MediaProcessor(cache);
});

// Data providers
final allPacksProvider = FutureProvider<List<StickerPack>>((ref) {
  return ref.read(packRepositoryProvider).getAllPacks();
});

final packStickersProvider = FutureProvider.family<List<Sticker>, int>((ref, packId) {
  return ref.read(stickerRepositoryProvider).getStickersForPack(packId);
});

// Settings
final themeProvider = StateProvider<bool>((ref) => false); // false = light
final telegramTokenProvider = StateProvider<String?>((ref) => null);
final localeProvider = StateProvider<Locale?>((ref) => null); // null = system default
final gridColumnsProvider = StateProvider<int>((ref) => 3);
