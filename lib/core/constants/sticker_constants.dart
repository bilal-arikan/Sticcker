class StickerConstants {
  StickerConstants._();

  // WhatsApp limits
  static const int whatsappStickerSize = 512;
  static const int whatsappTrayIconSize = 96;
  static const int whatsappMaxStaticSizeKB = 100;
  static const int whatsappMaxAnimatedSizeKB = 500;
  static const int whatsappMinStickersPerPack = 3;
  static const int whatsappMaxStickersPerPack = 30;

  // Telegram limits
  static const int telegramStickerSize = 512;
  static const int telegramMaxStaticSizeKB = 512;
  static const int telegramMaxVideoSizeKB = 256;
  static const int telegramMaxVideoDurationSec = 3;
  static const int telegramMaxAnimatedSizeKB = 64;
  static const int telegramMaxStickersPerPack = 120;

  // Supported input formats
  static const List<String> supportedImageFormats = [
    'png', 'jpg', 'jpeg', 'webp', 'bmp', 'heic', 'heif', 'svg', 'tiff', 'tif',
  ];

  static const List<String> supportedVideoFormats = [
    'mp4', 'mov', 'avi', 'mkv', 'webm',
  ];

  static const List<String> supportedGifFormats = ['gif'];

  static List<String> get allSupportedFormats =>
      [...supportedImageFormats, ...supportedVideoFormats, ...supportedGifFormats];

  // Cache
  static const int maxCacheSizeMB = 500;
  static const String processedCacheDir = 'processed_stickers';
  static const String thumbnailCacheDir = 'thumbnails';
  static const String sourcesDir = 'sticker_sources';
}

enum StickerType { image, animated, video }

enum ExportPlatform { whatsapp, telegram }

enum MediaType { image, video, gif }
