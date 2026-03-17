// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sticcker';

  @override
  String get newPack => 'New Pack';

  @override
  String get importFromTelegram => 'Import from Telegram';

  @override
  String get emptyPacksTitle => 'No sticker packs yet';

  @override
  String get emptyPacksSubtitle => 'Get started by creating a new pack';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get newStickerPack => 'New Sticker Pack';

  @override
  String get packName => 'Pack Name';

  @override
  String get packNameHint => 'e.g. Funny Cats';

  @override
  String get author => 'Author';

  @override
  String get authorHint => 'Your name';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get telegramBotTokenRequired =>
      'Please enter Telegram bot token in Settings first';

  @override
  String get telegramImportTitle => 'Import from Telegram';

  @override
  String get telegramImportInfo =>
      'Enter the sticker set name (e.g. Animals or Animals_by_BotName)';

  @override
  String get setName => 'Set Name';

  @override
  String get import_ => 'Import';

  @override
  String get importingFromTelegram => 'Importing from Telegram';

  @override
  String get starting => 'Starting...';

  @override
  String get downloadingStickerSet => 'Downloading sticker set...';

  @override
  String downloadingProgress(int current, int total) {
    return 'Downloading: $current/$total';
  }

  @override
  String get stickerSetEmptyOrFailed =>
      'Sticker set is empty or could not be downloaded';

  @override
  String get creatingPack => 'Creating pack...';

  @override
  String importedSuccess(String title, int count) {
    return '\"$title\" imported ($count stickers)';
  }

  @override
  String get close => 'Close';

  @override
  String stickerCountInfo(int count) {
    return '$count stickers';
  }

  @override
  String stickerCountWithAuthor(int count, String author) {
    return '$count stickers · $author';
  }

  @override
  String get pack => 'Pack';

  @override
  String get error => 'Error';

  @override
  String get exportToWhatsApp => 'Export to WhatsApp';

  @override
  String get exportToTelegram => 'Export to Telegram';

  @override
  String get deletePack => 'Delete Pack';

  @override
  String get addSticker => 'Add Sticker';

  @override
  String get addStickerSubtitle => 'Add from gallery, files, or camera';

  @override
  String processingProgress(int percent) {
    return 'Processing... $percent%';
  }

  @override
  String get deleteSticker => 'Delete Sticker';

  @override
  String get deleteStickerConfirm => 'Delete this sticker?';

  @override
  String get delete => 'Delete';

  @override
  String get editPack => 'Edit Pack';

  @override
  String get save => 'Save';

  @override
  String get deletePackConfirm =>
      'This pack and all its stickers will be deleted. Are you sure?';

  @override
  String get editSticker => 'Edit Sticker';

  @override
  String get crop => 'Crop';

  @override
  String get rotate => 'Rotate';

  @override
  String get text => 'Text';

  @override
  String get draw => 'Draw';

  @override
  String videoDuration(String start, String end) {
    return 'Video Duration: $start - $end';
  }

  @override
  String maxDurationTelegram(int seconds) {
    return 'Max. $seconds seconds (Telegram)';
  }

  @override
  String get emoji => 'Emoji: ';

  @override
  String get cropSticker => 'Crop Sticker';

  @override
  String get addText => 'Add Text';

  @override
  String get textHint => 'Type your text...';

  @override
  String get add => 'Add';

  @override
  String get textAdded => 'Text added';

  @override
  String get eraser => 'Eraser';

  @override
  String get drawingToolComingSoon => 'Drawing tool coming soon';

  @override
  String get stickerSaved => 'Sticker saved';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get telegramIntegration => 'Telegram Integration';

  @override
  String get cache => 'Cache';

  @override
  String get about => 'About';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get darkThemeSubtitle => 'Use the app in dark mode';

  @override
  String get botToken => 'Bot Token';

  @override
  String get botTokenHelper => 'Create a bot with @BotFather and get the token';

  @override
  String botConnected(String username) {
    return 'Bot connected: @$username';
  }

  @override
  String get cacheSize => 'Cache Size';

  @override
  String cacheSizeUsing(int size) {
    return 'Using $size MB';
  }

  @override
  String get clear => 'Clear';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheConfirm =>
      'All processed stickers will be deleted. Are you sure?';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get stickerSetName => 'Sticker Set Name';

  @override
  String get stickerSetNameHelper => 'Letters, numbers, and underscores only';

  @override
  String get telegramUserId => 'Telegram User ID';

  @override
  String get telegramUserIdHelper => 'You can find it with @userinfobot';

  @override
  String get sendToWhatsApp => 'Send to WhatsApp';

  @override
  String get sendToTelegram => 'Send to Telegram';

  @override
  String get preparingStickers => 'Preparing stickers...';

  @override
  String convertingProgress(int current, int total) {
    return 'Converting: $current/$total';
  }

  @override
  String get sendingToTelegram => 'Sending to Telegram...';

  @override
  String get packNotFound => 'Pack not found';

  @override
  String get setNameAndUserIdRequired => 'Set name and User ID are required';

  @override
  String get invalidUserId => 'Invalid User ID';

  @override
  String get telegramBotTokenNotConfigured =>
      'Telegram bot token must be configured in settings';

  @override
  String get sentToWhatsApp => 'Sent to WhatsApp!';

  @override
  String get sentToTelegram => 'Sent to Telegram!';

  @override
  String get ok => 'OK';

  @override
  String get copy => 'Copy';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Change app language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get turkish => 'Türkçe';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get korean => '한국어';

  @override
  String get spanish => 'Español';

  @override
  String get japanese => '日本語';

  @override
  String get gridColumns => 'Grid Columns';

  @override
  String get gridColumnsSubtitle => 'Number of columns in sticker grid';

  @override
  String stickerLimitExceeded(int max, int skipped) {
    return 'Pack limit exceeded. Maximum $max stickers allowed, $skipped skipped.';
  }

  @override
  String someStickersNotProcessed(int count) {
    return '$count stickers could not be processed';
  }

  @override
  String get failedFiles => 'Failed Files';

  @override
  String failedFileReason(String fileName, String reason) {
    return '$fileName: $reason';
  }

  @override
  String convertingDetail(int current, int total, String fileName) {
    return 'Converting: $current/$total — $fileName';
  }

  @override
  String convertedSize(int size) {
    return 'Converted: $size KB';
  }

  @override
  String get creatingTrayIcon => 'Creating tray icon...';

  @override
  String get sendingToWhatsApp => 'Sending to WhatsApp...';

  @override
  String get errorDetails => 'Error Details';
}
