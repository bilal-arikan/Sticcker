import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sticcker'**
  String get appTitle;

  /// No description provided for @newPack.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Paket'**
  String get newPack;

  /// No description provided for @importFromTelegram.
  ///
  /// In tr, this message translates to:
  /// **'Telegram\'dan Aktar'**
  String get importFromTelegram;

  /// No description provided for @emptyPacksTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz sticker paketin yok'**
  String get emptyPacksTitle;

  /// No description provided for @emptyPacksSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bir paket oluşturarak başlayabilirsin'**
  String get emptyPacksSubtitle;

  /// No description provided for @errorGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Hata: {error}'**
  String errorGeneric(String error);

  /// No description provided for @newStickerPack.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Sticker Paketi'**
  String get newStickerPack;

  /// No description provided for @packName.
  ///
  /// In tr, this message translates to:
  /// **'Paket Adı'**
  String get packName;

  /// No description provided for @packNameHint.
  ///
  /// In tr, this message translates to:
  /// **'örnek: Komik Kediler'**
  String get packNameHint;

  /// No description provided for @author.
  ///
  /// In tr, this message translates to:
  /// **'Yazar'**
  String get author;

  /// No description provided for @authorHint.
  ///
  /// In tr, this message translates to:
  /// **'Senin ismin'**
  String get authorHint;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In tr, this message translates to:
  /// **'Oluştur'**
  String get create;

  /// No description provided for @telegramBotTokenRequired.
  ///
  /// In tr, this message translates to:
  /// **'Öncelikle Ayarlar\'dan Telegram bot token girin'**
  String get telegramBotTokenRequired;

  /// No description provided for @telegramImportTitle.
  ///
  /// In tr, this message translates to:
  /// **'Telegram\'dan Aktar'**
  String get telegramImportTitle;

  /// No description provided for @telegramImportInfo.
  ///
  /// In tr, this message translates to:
  /// **'Sticker setinin adını girin (örn: Animals veya Animals_by_BotName)'**
  String get telegramImportInfo;

  /// No description provided for @setName.
  ///
  /// In tr, this message translates to:
  /// **'Set Adı'**
  String get setName;

  /// No description provided for @import_.
  ///
  /// In tr, this message translates to:
  /// **'Aktar'**
  String get import_;

  /// No description provided for @importingFromTelegram.
  ///
  /// In tr, this message translates to:
  /// **'Telegram\'dan Aktarılıyor'**
  String get importingFromTelegram;

  /// No description provided for @starting.
  ///
  /// In tr, this message translates to:
  /// **'Başlanıyor...'**
  String get starting;

  /// No description provided for @downloadingStickerSet.
  ///
  /// In tr, this message translates to:
  /// **'Sticker seti indiriliyor...'**
  String get downloadingStickerSet;

  /// No description provided for @downloadingProgress.
  ///
  /// In tr, this message translates to:
  /// **'İndiriliyor: {current}/{total}'**
  String downloadingProgress(int current, int total);

  /// No description provided for @stickerSetEmptyOrFailed.
  ///
  /// In tr, this message translates to:
  /// **'Sticker seti boş veya indirilemedi'**
  String get stickerSetEmptyOrFailed;

  /// No description provided for @creatingPack.
  ///
  /// In tr, this message translates to:
  /// **'Paket oluşturuluyor...'**
  String get creatingPack;

  /// No description provided for @importedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'\"{title}\" aktarıldı ({count} sticker)'**
  String importedSuccess(String title, int count);

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @stickerCountInfo.
  ///
  /// In tr, this message translates to:
  /// **'{count} sticker'**
  String stickerCountInfo(int count);

  /// No description provided for @stickerCountWithAuthor.
  ///
  /// In tr, this message translates to:
  /// **'{count} sticker · {author}'**
  String stickerCountWithAuthor(int count, String author);

  /// No description provided for @pack.
  ///
  /// In tr, this message translates to:
  /// **'Paket'**
  String get pack;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// No description provided for @exportToWhatsApp.
  ///
  /// In tr, this message translates to:
  /// **'WhatsApp\'a Aktar'**
  String get exportToWhatsApp;

  /// No description provided for @exportToTelegram.
  ///
  /// In tr, this message translates to:
  /// **'Telegram\'a Aktar'**
  String get exportToTelegram;

  /// No description provided for @deletePack.
  ///
  /// In tr, this message translates to:
  /// **'Paketi Sil'**
  String get deletePack;

  /// No description provided for @addSticker.
  ///
  /// In tr, this message translates to:
  /// **'Sticker ekle'**
  String get addSticker;

  /// No description provided for @addStickerSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Galeri, dosya veya kamera ile ekleyebilirsin'**
  String get addStickerSubtitle;

  /// No description provided for @processingProgress.
  ///
  /// In tr, this message translates to:
  /// **'İşleniyor... {percent}%'**
  String processingProgress(int percent);

  /// No description provided for @deleteSticker.
  ///
  /// In tr, this message translates to:
  /// **'Sticker Sil'**
  String get deleteSticker;

  /// No description provided for @deleteStickerConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu sticker silinsin mi?'**
  String get deleteStickerConfirm;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @editPack.
  ///
  /// In tr, this message translates to:
  /// **'Paketi Düzenle'**
  String get editPack;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @deletePackConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu paket ve tüm stickerları silinecek. Emin misin?'**
  String get deletePackConfirm;

  /// No description provided for @editSticker.
  ///
  /// In tr, this message translates to:
  /// **'Sticker Düzenle'**
  String get editSticker;

  /// No description provided for @crop.
  ///
  /// In tr, this message translates to:
  /// **'Kırp'**
  String get crop;

  /// No description provided for @rotate.
  ///
  /// In tr, this message translates to:
  /// **'Döndür'**
  String get rotate;

  /// No description provided for @text.
  ///
  /// In tr, this message translates to:
  /// **'Metin'**
  String get text;

  /// No description provided for @draw.
  ///
  /// In tr, this message translates to:
  /// **'Çiz'**
  String get draw;

  /// No description provided for @videoDuration.
  ///
  /// In tr, this message translates to:
  /// **'Video Süresi: {start} - {end}'**
  String videoDuration(String start, String end);

  /// No description provided for @maxDurationTelegram.
  ///
  /// In tr, this message translates to:
  /// **'Maks. {seconds} saniye (Telegram)'**
  String maxDurationTelegram(int seconds);

  /// No description provided for @emoji.
  ///
  /// In tr, this message translates to:
  /// **'Emoji: '**
  String get emoji;

  /// No description provided for @cropSticker.
  ///
  /// In tr, this message translates to:
  /// **'Sticker Kırp'**
  String get cropSticker;

  /// No description provided for @addText.
  ///
  /// In tr, this message translates to:
  /// **'Metin Ekle'**
  String get addText;

  /// No description provided for @textHint.
  ///
  /// In tr, this message translates to:
  /// **'Metnini yaz...'**
  String get textHint;

  /// No description provided for @add.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  /// No description provided for @textAdded.
  ///
  /// In tr, this message translates to:
  /// **'Metin eklendi'**
  String get textAdded;

  /// No description provided for @eraser.
  ///
  /// In tr, this message translates to:
  /// **'Silgi'**
  String get eraser;

  /// No description provided for @drawingToolComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Çizim aracı yakında eklenecek'**
  String get drawingToolComingSoon;

  /// No description provided for @stickerSaved.
  ///
  /// In tr, this message translates to:
  /// **'Sticker kaydedildi'**
  String get stickerSaved;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get appearance;

  /// No description provided for @telegramIntegration.
  ///
  /// In tr, this message translates to:
  /// **'Telegram Entegrasyonu'**
  String get telegramIntegration;

  /// No description provided for @cache.
  ///
  /// In tr, this message translates to:
  /// **'Önbellek'**
  String get cache;

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// No description provided for @darkTheme.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık Tema'**
  String get darkTheme;

  /// No description provided for @darkThemeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı karanlık modda kullan'**
  String get darkThemeSubtitle;

  /// No description provided for @botToken.
  ///
  /// In tr, this message translates to:
  /// **'Bot Token'**
  String get botToken;

  /// No description provided for @botTokenHelper.
  ///
  /// In tr, this message translates to:
  /// **'@BotFather ile bot oluştur ve token al'**
  String get botTokenHelper;

  /// No description provided for @botConnected.
  ///
  /// In tr, this message translates to:
  /// **'Bot bağlandı: @{username}'**
  String botConnected(String username);

  /// No description provided for @cacheSize.
  ///
  /// In tr, this message translates to:
  /// **'Önbellek Boyutu'**
  String get cacheSize;

  /// No description provided for @cacheSizeUsing.
  ///
  /// In tr, this message translates to:
  /// **'{size} MB kullanılıyor'**
  String cacheSizeUsing(int size);

  /// No description provided for @clear.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get clear;

  /// No description provided for @clearCache.
  ///
  /// In tr, this message translates to:
  /// **'Önbellek Temizle'**
  String get clearCache;

  /// No description provided for @clearCacheConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Tüm işlenmiş stickerlar silinecek. Emin misin?'**
  String get clearCacheConfirm;

  /// No description provided for @cacheCleared.
  ///
  /// In tr, this message translates to:
  /// **'Önbellek temizlendi'**
  String get cacheCleared;

  /// No description provided for @openSourceLicenses.
  ///
  /// In tr, this message translates to:
  /// **'Açık Kaynak Lisanslar'**
  String get openSourceLicenses;

  /// No description provided for @stickerSetName.
  ///
  /// In tr, this message translates to:
  /// **'Sticker Set Adı'**
  String get stickerSetName;

  /// No description provided for @stickerSetNameHelper.
  ///
  /// In tr, this message translates to:
  /// **'Sadece harf, rakam ve alt çizgi'**
  String get stickerSetNameHelper;

  /// No description provided for @telegramUserId.
  ///
  /// In tr, this message translates to:
  /// **'Telegram User ID'**
  String get telegramUserId;

  /// No description provided for @telegramUserIdHelper.
  ///
  /// In tr, this message translates to:
  /// **'@userinfobot ile öğrenebilirsin'**
  String get telegramUserIdHelper;

  /// No description provided for @sendToWhatsApp.
  ///
  /// In tr, this message translates to:
  /// **'WhatsApp\'a Gönder'**
  String get sendToWhatsApp;

  /// No description provided for @sendToTelegram.
  ///
  /// In tr, this message translates to:
  /// **'Telegram\'a Gönder'**
  String get sendToTelegram;

  /// No description provided for @preparingStickers.
  ///
  /// In tr, this message translates to:
  /// **'Stickerlar hazırlanıyor...'**
  String get preparingStickers;

  /// No description provided for @convertingProgress.
  ///
  /// In tr, this message translates to:
  /// **'Dönüştürülüyor: {current}/{total}'**
  String convertingProgress(int current, int total);

  /// No description provided for @sendingToTelegram.
  ///
  /// In tr, this message translates to:
  /// **'Telegram\'a gönderiliyor...'**
  String get sendingToTelegram;

  /// No description provided for @packNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Paket bulunamadı'**
  String get packNotFound;

  /// No description provided for @setNameAndUserIdRequired.
  ///
  /// In tr, this message translates to:
  /// **'Set adı ve User ID gerekli'**
  String get setNameAndUserIdRequired;

  /// No description provided for @invalidUserId.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz User ID'**
  String get invalidUserId;

  /// No description provided for @telegramBotTokenNotConfigured.
  ///
  /// In tr, this message translates to:
  /// **'Telegram bot token ayarlarından yapılandırılmalı'**
  String get telegramBotTokenNotConfigured;

  /// No description provided for @sentToWhatsApp.
  ///
  /// In tr, this message translates to:
  /// **'WhatsApp\'a gönderildi!'**
  String get sentToWhatsApp;

  /// No description provided for @sentToTelegram.
  ///
  /// In tr, this message translates to:
  /// **'Telegram\'a gönderildi!'**
  String get sentToTelegram;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @copy.
  ///
  /// In tr, this message translates to:
  /// **'Kopyala'**
  String get copy;

  /// No description provided for @copiedToClipboard.
  ///
  /// In tr, this message translates to:
  /// **'Panoya kopyalandı'**
  String get copiedToClipboard;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama dilini değiştir'**
  String get languageSubtitle;

  /// No description provided for @systemDefault.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Varsayılanı'**
  String get systemDefault;

  /// No description provided for @turkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @russian.
  ///
  /// In tr, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @korean.
  ///
  /// In tr, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @spanish.
  ///
  /// In tr, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @japanese.
  ///
  /// In tr, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @gridColumns.
  ///
  /// In tr, this message translates to:
  /// **'Sütun Sayısı'**
  String get gridColumns;

  /// No description provided for @gridColumnsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sticker ızgarasındaki sütun sayısı'**
  String get gridColumnsSubtitle;

  /// No description provided for @stickerLimitExceeded.
  ///
  /// In tr, this message translates to:
  /// **'Paket limiti aşılıyor. En fazla {max} sticker eklenebilir, {skipped} tanesi atlandı.'**
  String stickerLimitExceeded(int max, int skipped);

  /// No description provided for @someStickersNotProcessed.
  ///
  /// In tr, this message translates to:
  /// **'{count} sticker işlenemedi'**
  String someStickersNotProcessed(int count);

  /// No description provided for @failedFiles.
  ///
  /// In tr, this message translates to:
  /// **'Başarısız Dosyalar'**
  String get failedFiles;

  /// No description provided for @failedFileReason.
  ///
  /// In tr, this message translates to:
  /// **'{fileName}: {reason}'**
  String failedFileReason(String fileName, String reason);

  /// No description provided for @convertingDetail.
  ///
  /// In tr, this message translates to:
  /// **'Dönüştürülüyor: {current}/{total} — {fileName}'**
  String convertingDetail(int current, int total, String fileName);

  /// No description provided for @convertedSize.
  ///
  /// In tr, this message translates to:
  /// **'Dönüştürüldü: {size} KB'**
  String convertedSize(int size);

  /// No description provided for @creatingTrayIcon.
  ///
  /// In tr, this message translates to:
  /// **'Tray ikonu oluşturuluyor...'**
  String get creatingTrayIcon;

  /// No description provided for @sendingToWhatsApp.
  ///
  /// In tr, this message translates to:
  /// **'WhatsApp\'a gönderiliyor...'**
  String get sendingToWhatsApp;

  /// No description provided for @errorDetails.
  ///
  /// In tr, this message translates to:
  /// **'Hata Detayı'**
  String get errorDetails;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'ja',
    'ko',
    'ru',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
    case 'ja':
      return SJa();
    case 'ko':
      return SKo();
    case 'ru':
      return SRu();
    case 'tr':
      return STr();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
