// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class STr extends S {
  STr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Sticcker';

  @override
  String get newPack => 'Yeni Paket';

  @override
  String get importFromTelegram => 'Telegram\'dan Aktar';

  @override
  String get emptyPacksTitle => 'Henüz sticker paketin yok';

  @override
  String get emptyPacksSubtitle => 'Yeni bir paket oluşturarak başlayabilirsin';

  @override
  String errorGeneric(String error) {
    return 'Hata: $error';
  }

  @override
  String get newStickerPack => 'Yeni Sticker Paketi';

  @override
  String get packName => 'Paket Adı';

  @override
  String get packNameHint => 'örnek: Komik Kediler';

  @override
  String get author => 'Yazar';

  @override
  String get authorHint => 'Senin ismin';

  @override
  String get cancel => 'İptal';

  @override
  String get create => 'Oluştur';

  @override
  String get telegramBotTokenRequired =>
      'Öncelikle Ayarlar\'dan Telegram bot token girin';

  @override
  String get telegramImportTitle => 'Telegram\'dan Aktar';

  @override
  String get telegramImportInfo =>
      'Sticker setinin adını girin (örn: Animals veya Animals_by_BotName)';

  @override
  String get setName => 'Set Adı';

  @override
  String get import_ => 'Aktar';

  @override
  String get importingFromTelegram => 'Telegram\'dan Aktarılıyor';

  @override
  String get starting => 'Başlanıyor...';

  @override
  String get downloadingStickerSet => 'Sticker seti indiriliyor...';

  @override
  String downloadingProgress(int current, int total) {
    return 'İndiriliyor: $current/$total';
  }

  @override
  String get stickerSetEmptyOrFailed => 'Sticker seti boş veya indirilemedi';

  @override
  String get creatingPack => 'Paket oluşturuluyor...';

  @override
  String importedSuccess(String title, int count) {
    return '\"$title\" aktarıldı ($count sticker)';
  }

  @override
  String get close => 'Kapat';

  @override
  String stickerCountInfo(int count) {
    return '$count sticker';
  }

  @override
  String stickerCountWithAuthor(int count, String author) {
    return '$count sticker · $author';
  }

  @override
  String get pack => 'Paket';

  @override
  String get error => 'Hata';

  @override
  String get exportToWhatsApp => 'WhatsApp\'a Aktar';

  @override
  String get exportToTelegram => 'Telegram\'a Aktar';

  @override
  String get deletePack => 'Paketi Sil';

  @override
  String get addSticker => 'Sticker ekle';

  @override
  String get addStickerSubtitle =>
      'Galeri, dosya veya kamera ile ekleyebilirsin';

  @override
  String processingProgress(int percent) {
    return 'İşleniyor... $percent%';
  }

  @override
  String get deleteSticker => 'Sticker Sil';

  @override
  String get deleteStickerConfirm => 'Bu sticker silinsin mi?';

  @override
  String get delete => 'Sil';

  @override
  String get editPack => 'Paketi Düzenle';

  @override
  String get save => 'Kaydet';

  @override
  String get deletePackConfirm =>
      'Bu paket ve tüm stickerları silinecek. Emin misin?';

  @override
  String get editSticker => 'Sticker Düzenle';

  @override
  String get crop => 'Kırp';

  @override
  String get rotate => 'Döndür';

  @override
  String get text => 'Metin';

  @override
  String get draw => 'Çiz';

  @override
  String videoDuration(String start, String end) {
    return 'Video Süresi: $start - $end';
  }

  @override
  String maxDurationTelegram(int seconds) {
    return 'Maks. $seconds saniye (Telegram)';
  }

  @override
  String get emoji => 'Emoji: ';

  @override
  String get cropSticker => 'Sticker Kırp';

  @override
  String get addText => 'Metin Ekle';

  @override
  String get textHint => 'Metnini yaz...';

  @override
  String get add => 'Ekle';

  @override
  String get textAdded => 'Metin eklendi';

  @override
  String get drawingToolComingSoon => 'Çizim aracı yakında eklenecek';

  @override
  String get stickerSaved => 'Sticker kaydedildi';

  @override
  String get settings => 'Ayarlar';

  @override
  String get appearance => 'Görünüm';

  @override
  String get telegramIntegration => 'Telegram Entegrasyonu';

  @override
  String get cache => 'Önbellek';

  @override
  String get about => 'Hakkında';

  @override
  String get darkTheme => 'Karanlık Tema';

  @override
  String get darkThemeSubtitle => 'Uygulamayı karanlık modda kullan';

  @override
  String get botToken => 'Bot Token';

  @override
  String get botTokenHelper => '@BotFather ile bot oluştur ve token al';

  @override
  String botConnected(String username) {
    return 'Bot bağlandı: @$username';
  }

  @override
  String get cacheSize => 'Önbellek Boyutu';

  @override
  String cacheSizeUsing(int size) {
    return '$size MB kullanılıyor';
  }

  @override
  String get clear => 'Temizle';

  @override
  String get clearCache => 'Önbellek Temizle';

  @override
  String get clearCacheConfirm =>
      'Tüm işlenmiş stickerlar silinecek. Emin misin?';

  @override
  String get cacheCleared => 'Önbellek temizlendi';

  @override
  String get openSourceLicenses => 'Açık Kaynak Lisanslar';

  @override
  String get stickerSetName => 'Sticker Set Adı';

  @override
  String get stickerSetNameHelper => 'Sadece harf, rakam ve alt çizgi';

  @override
  String get telegramUserId => 'Telegram User ID';

  @override
  String get telegramUserIdHelper => '@userinfobot ile öğrenebilirsin';

  @override
  String get sendToWhatsApp => 'WhatsApp\'a Gönder';

  @override
  String get sendToTelegram => 'Telegram\'a Gönder';

  @override
  String get preparingStickers => 'Stickerlar hazırlanıyor...';

  @override
  String convertingProgress(int current, int total) {
    return 'Dönüştürülüyor: $current/$total';
  }

  @override
  String get sendingToTelegram => 'Telegram\'a gönderiliyor...';

  @override
  String get packNotFound => 'Paket bulunamadı';

  @override
  String get setNameAndUserIdRequired => 'Set adı ve User ID gerekli';

  @override
  String get invalidUserId => 'Geçersiz User ID';

  @override
  String get telegramBotTokenNotConfigured =>
      'Telegram bot token ayarlarından yapılandırılmalı';

  @override
  String get sentToWhatsApp => 'WhatsApp\'a gönderildi!';

  @override
  String get sentToTelegram => 'Telegram\'a gönderildi!';

  @override
  String get ok => 'Tamam';

  @override
  String get copy => 'Kopyala';

  @override
  String get copiedToClipboard => 'Panoya kopyalandı';

  @override
  String get language => 'Dil';

  @override
  String get languageSubtitle => 'Uygulama dilini değiştir';

  @override
  String get systemDefault => 'Sistem Varsayılanı';

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
  String get gridColumns => 'Sütun Sayısı';

  @override
  String get gridColumnsSubtitle => 'Sticker ızgarasındaki sütun sayısı';

  @override
  String stickerLimitExceeded(int max, int skipped) {
    return 'Paket limiti aşılıyor. En fazla $max sticker eklenebilir, $skipped tanesi atlandı.';
  }

  @override
  String someStickersNotProcessed(int count) {
    return '$count sticker işlenemedi';
  }

  @override
  String get failedFiles => 'Başarısız Dosyalar';

  @override
  String failedFileReason(String fileName, String reason) {
    return '$fileName: $reason';
  }

  @override
  String convertingDetail(int current, int total, String fileName) {
    return 'Dönüştürülüyor: $current/$total — $fileName';
  }

  @override
  String convertedSize(int size) {
    return 'Dönüştürüldü: $size KB';
  }

  @override
  String get creatingTrayIcon => 'Tray ikonu oluşturuluyor...';

  @override
  String get sendingToWhatsApp => 'WhatsApp\'a gönderiliyor...';

  @override
  String get errorDetails => 'Hata Detayı';
}
