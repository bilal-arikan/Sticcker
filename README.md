# Sticcker

A sticker pack creator for **WhatsApp** and **Telegram**, built with Flutter.

<p align="center">
  <img src="https://github.com/user-attachments/assets/d766cc8a-6b1f-4540-bf90-27b9c47917c3" width="30%" />
  <img src="https://github.com/user-attachments/assets/f34907e3-84e6-48cc-a69c-f89b190ab86e" width="30%" />
  <img src="https://github.com/user-attachments/assets/04de38ab-8217-4419-9908-7cce419f4533" width="30%" />
</p>


## Features

- Create custom sticker packs from images, videos, and GIFs
- Export sticker packs directly to WhatsApp (Android)
- Export sticker packs to Telegram via Bot API
- Import existing sticker sets from Telegram
- Built-in sticker editor (crop, rotate, text overlay)
- Support for both static and animated stickers
- Automatic format conversion and size optimization
- Dark mode support
- Localized in English and Turkish

## Tech Stack

- **Flutter** (Dart)
- **Riverpod** for state management
- **sqflite** for local database
- **FFmpeg** (`ffmpeg_kit_flutter_new`) for media processing
- **Android ContentProvider** for WhatsApp sticker integration

## Getting Started

```bash
flutter pub get
flutter run
```

## WhatsApp Sticker Requirements

| Type     | Format       | Size   | Max File Size |
|----------|-------------|--------|---------------|
| Static   | WebP 512x512 | Square | 100 KB        |
| Animated | WebP 512x512 | Square | 500 KB        |

- Minimum 3 stickers per pack, maximum 30
- Tray icon: 96x96 WebP, max 50 KB

## License

MIT
