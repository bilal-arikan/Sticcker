// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class SRu extends S {
  SRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Sticcker';

  @override
  String get newPack => 'Новый набор';

  @override
  String get importFromTelegram => 'Импорт из Telegram';

  @override
  String get emptyPacksTitle => 'Пока нет наборов стикеров';

  @override
  String get emptyPacksSubtitle => 'Начните с создания нового набора';

  @override
  String errorGeneric(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get newStickerPack => 'Новый набор стикеров';

  @override
  String get packName => 'Название набора';

  @override
  String get packNameHint => 'например: Смешные коты';

  @override
  String get author => 'Автор';

  @override
  String get authorHint => 'Ваше имя';

  @override
  String get cancel => 'Отмена';

  @override
  String get create => 'Создать';

  @override
  String get telegramBotTokenRequired =>
      'Сначала введите токен Telegram бота в настройках';

  @override
  String get telegramImportTitle => 'Импорт из Telegram';

  @override
  String get telegramImportInfo =>
      'Введите имя набора стикеров (например: Animals или Animals_by_BotName)';

  @override
  String get setName => 'Имя набора';

  @override
  String get import_ => 'Импорт';

  @override
  String get importingFromTelegram => 'Импорт из Telegram';

  @override
  String get starting => 'Начало...';

  @override
  String get downloadingStickerSet => 'Загрузка набора стикеров...';

  @override
  String downloadingProgress(int current, int total) {
    return 'Загрузка: $current/$total';
  }

  @override
  String get stickerSetEmptyOrFailed =>
      'Набор стикеров пуст или не удалось загрузить';

  @override
  String get creatingPack => 'Создание набора...';

  @override
  String importedSuccess(String title, int count) {
    return '\"$title\" импортирован ($count стикеров)';
  }

  @override
  String get close => 'Закрыть';

  @override
  String stickerCountInfo(int count) {
    return '$count стикеров';
  }

  @override
  String stickerCountWithAuthor(int count, String author) {
    return '$count стикеров · $author';
  }

  @override
  String get pack => 'Набор';

  @override
  String get error => 'Ошибка';

  @override
  String get exportToWhatsApp => 'Экспорт в WhatsApp';

  @override
  String get exportToTelegram => 'Экспорт в Telegram';

  @override
  String get deletePack => 'Удалить набор';

  @override
  String get addSticker => 'Добавить стикер';

  @override
  String get addStickerSubtitle => 'Добавить из галереи, файлов или камеры';

  @override
  String processingProgress(int percent) {
    return 'Обработка... $percent%';
  }

  @override
  String get deleteSticker => 'Удалить стикер';

  @override
  String get deleteStickerConfirm => 'Удалить этот стикер?';

  @override
  String get delete => 'Удалить';

  @override
  String get editPack => 'Редактировать набор';

  @override
  String get save => 'Сохранить';

  @override
  String get deletePackConfirm =>
      'Этот набор и все его стикеры будут удалены. Вы уверены?';

  @override
  String get editSticker => 'Редактировать стикер';

  @override
  String get crop => 'Обрезка';

  @override
  String get rotate => 'Поворот';

  @override
  String get text => 'Текст';

  @override
  String get draw => 'Рисовать';

  @override
  String videoDuration(String start, String end) {
    return 'Длительность видео: $start - $end';
  }

  @override
  String maxDurationTelegram(int seconds) {
    return 'Макс. $seconds секунд (Telegram)';
  }

  @override
  String get emoji => 'Эмодзи: ';

  @override
  String get cropSticker => 'Обрезать стикер';

  @override
  String get addText => 'Добавить текст';

  @override
  String get textHint => 'Введите текст...';

  @override
  String get add => 'Добавить';

  @override
  String get textAdded => 'Текст добавлен';

  @override
  String get drawingToolComingSoon => 'Инструмент рисования скоро будет';

  @override
  String get stickerSaved => 'Стикер сохранён';

  @override
  String get settings => 'Настройки';

  @override
  String get appearance => 'Оформление';

  @override
  String get telegramIntegration => 'Интеграция с Telegram';

  @override
  String get cache => 'Кэш';

  @override
  String get about => 'О приложении';

  @override
  String get darkTheme => 'Тёмная тема';

  @override
  String get darkThemeSubtitle => 'Использовать приложение в тёмном режиме';

  @override
  String get botToken => 'Токен бота';

  @override
  String get botTokenHelper =>
      'Создайте бота через @BotFather и получите токен';

  @override
  String botConnected(String username) {
    return 'Бот подключён: @$username';
  }

  @override
  String get cacheSize => 'Размер кэша';

  @override
  String cacheSizeUsing(int size) {
    return 'Используется $size МБ';
  }

  @override
  String get clear => 'Очистить';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get clearCacheConfirm =>
      'Все обработанные стикеры будут удалены. Вы уверены?';

  @override
  String get cacheCleared => 'Кэш очищен';

  @override
  String get openSourceLicenses => 'Лицензии открытого ПО';

  @override
  String get stickerSetName => 'Имя набора стикеров';

  @override
  String get stickerSetNameHelper => 'Только буквы, цифры и подчёркивания';

  @override
  String get telegramUserId => 'Telegram User ID';

  @override
  String get telegramUserIdHelper => 'Узнайте через @userinfobot';

  @override
  String get sendToWhatsApp => 'Отправить в WhatsApp';

  @override
  String get sendToTelegram => 'Отправить в Telegram';

  @override
  String get preparingStickers => 'Подготовка стикеров...';

  @override
  String convertingProgress(int current, int total) {
    return 'Конвертация: $current/$total';
  }

  @override
  String get sendingToTelegram => 'Отправка в Telegram...';

  @override
  String get packNotFound => 'Набор не найден';

  @override
  String get setNameAndUserIdRequired => 'Имя набора и User ID обязательны';

  @override
  String get invalidUserId => 'Недействительный User ID';

  @override
  String get telegramBotTokenNotConfigured =>
      'Токен Telegram бота должен быть настроен в настройках';

  @override
  String get sentToWhatsApp => 'Отправлено в WhatsApp!';

  @override
  String get sentToTelegram => 'Отправлено в Telegram!';

  @override
  String get ok => 'ОК';

  @override
  String get copy => 'Копировать';

  @override
  String get copiedToClipboard => 'Скопировано в буфер обмена';

  @override
  String get language => 'Язык';

  @override
  String get languageSubtitle => 'Изменить язык приложения';

  @override
  String get systemDefault => 'Системный по умолчанию';

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
  String get gridColumns => 'Количество столбцов';

  @override
  String get gridColumnsSubtitle => 'Количество столбцов в сетке стикеров';

  @override
  String stickerLimitExceeded(int max, int skipped) {
    return 'Лимит набора превышен. Максимум $max стикеров, $skipped пропущено.';
  }

  @override
  String someStickersNotProcessed(int count) {
    return '$count стикеров не удалось обработать';
  }

  @override
  String get failedFiles => 'Неудачные файлы';

  @override
  String failedFileReason(String fileName, String reason) {
    return '$fileName: $reason';
  }

  @override
  String convertingDetail(int current, int total, String fileName) {
    return 'Конвертация: $current/$total — $fileName';
  }

  @override
  String convertedSize(int size) {
    return 'Сконвертировано: $size КБ';
  }

  @override
  String get creatingTrayIcon => 'Создание иконки трея...';

  @override
  String get sendingToWhatsApp => 'Отправка в WhatsApp...';

  @override
  String get errorDetails => 'Подробности ошибки';
}
