// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class SJa extends S {
  SJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Sticcker';

  @override
  String get newPack => '新しいパック';

  @override
  String get importFromTelegram => 'Telegramからインポート';

  @override
  String get emptyPacksTitle => 'まだステッカーパックがありません';

  @override
  String get emptyPacksSubtitle => '新しいパックを作成して始めましょう';

  @override
  String errorGeneric(String error) {
    return 'エラー: $error';
  }

  @override
  String get newStickerPack => '新しいステッカーパック';

  @override
  String get packName => 'パック名';

  @override
  String get packNameHint => '例: おもしろい猫';

  @override
  String get author => '作成者';

  @override
  String get authorHint => 'あなたの名前';

  @override
  String get cancel => 'キャンセル';

  @override
  String get create => '作成';

  @override
  String get telegramBotTokenRequired => 'まず設定でTelegramボットトークンを入力してください';

  @override
  String get telegramImportTitle => 'Telegramからインポート';

  @override
  String get telegramImportInfo =>
      'ステッカーセット名を入力してください（例: Animals または Animals_by_BotName）';

  @override
  String get setName => 'セット名';

  @override
  String get import_ => 'インポート';

  @override
  String get importingFromTelegram => 'Telegramからインポート中';

  @override
  String get starting => '開始中...';

  @override
  String get downloadingStickerSet => 'ステッカーセットをダウンロード中...';

  @override
  String downloadingProgress(int current, int total) {
    return 'ダウンロード中: $current/$total';
  }

  @override
  String get stickerSetEmptyOrFailed => 'ステッカーセットが空か、ダウンロードできませんでした';

  @override
  String get creatingPack => 'パック作成中...';

  @override
  String importedSuccess(String title, int count) {
    return '「$title」をインポートしました（$count個のステッカー）';
  }

  @override
  String get close => '閉じる';

  @override
  String stickerCountInfo(int count) {
    return '$count個のステッカー';
  }

  @override
  String stickerCountWithAuthor(int count, String author) {
    return '$count個のステッカー · $author';
  }

  @override
  String get pack => 'パック';

  @override
  String get error => 'エラー';

  @override
  String get exportToWhatsApp => 'WhatsAppにエクスポート';

  @override
  String get exportToTelegram => 'Telegramにエクスポート';

  @override
  String get deletePack => 'パックを削除';

  @override
  String get addSticker => 'ステッカーを追加';

  @override
  String get addStickerSubtitle => 'ギャラリー、ファイル、カメラから追加';

  @override
  String processingProgress(int percent) {
    return '処理中... $percent%';
  }

  @override
  String get deleteSticker => 'ステッカーを削除';

  @override
  String get deleteStickerConfirm => 'このステッカーを削除しますか？';

  @override
  String get delete => '削除';

  @override
  String get editPack => 'パックを編集';

  @override
  String get save => '保存';

  @override
  String get deletePackConfirm => 'このパックとすべてのステッカーが削除されます。よろしいですか？';

  @override
  String get editSticker => 'ステッカーを編集';

  @override
  String get crop => '切り抜き';

  @override
  String get rotate => '回転';

  @override
  String get text => 'テキスト';

  @override
  String get draw => '描画';

  @override
  String videoDuration(String start, String end) {
    return '動画の長さ: $start - $end';
  }

  @override
  String maxDurationTelegram(int seconds) {
    return '最大 $seconds秒（Telegram）';
  }

  @override
  String get emoji => '絵文字: ';

  @override
  String get cropSticker => 'ステッカーを切り抜き';

  @override
  String get addText => 'テキストを追加';

  @override
  String get textHint => 'テキストを入力...';

  @override
  String get add => '追加';

  @override
  String get textAdded => 'テキストを追加しました';

  @override
  String get eraser => '消しゴム';

  @override
  String get drawingToolComingSoon => '描画ツールは近日公開予定';

  @override
  String get stickerSaved => 'ステッカーを保存しました';

  @override
  String get settings => '設定';

  @override
  String get appearance => '外観';

  @override
  String get telegramIntegration => 'Telegram連携';

  @override
  String get cache => 'キャッシュ';

  @override
  String get about => 'アプリについて';

  @override
  String get darkTheme => 'ダークテーマ';

  @override
  String get darkThemeSubtitle => 'アプリをダークモードで使用';

  @override
  String get botToken => 'ボットトークン';

  @override
  String get botTokenHelper => '@BotFatherでボットを作成しトークンを取得';

  @override
  String botConnected(String username) {
    return 'ボット接続済み: @$username';
  }

  @override
  String get cacheSize => 'キャッシュサイズ';

  @override
  String cacheSizeUsing(int size) {
    return '$size MB使用中';
  }

  @override
  String get clear => 'クリア';

  @override
  String get clearCache => 'キャッシュをクリア';

  @override
  String get clearCacheConfirm => '処理済みのすべてのステッカーが削除されます。よろしいですか？';

  @override
  String get cacheCleared => 'キャッシュをクリアしました';

  @override
  String get openSourceLicenses => 'オープンソースライセンス';

  @override
  String get stickerSetName => 'ステッカーセット名';

  @override
  String get stickerSetNameHelper => '英字、数字、アンダースコアのみ';

  @override
  String get telegramUserId => 'Telegram ユーザーID';

  @override
  String get telegramUserIdHelper => '@userinfobot で確認できます';

  @override
  String get sendToWhatsApp => 'WhatsAppに送信';

  @override
  String get sendToTelegram => 'Telegramに送信';

  @override
  String get preparingStickers => 'ステッカーを準備中...';

  @override
  String convertingProgress(int current, int total) {
    return '変換中: $current/$total';
  }

  @override
  String get sendingToTelegram => 'Telegramに送信中...';

  @override
  String get packNotFound => 'パックが見つかりません';

  @override
  String get setNameAndUserIdRequired => 'セット名とユーザーIDが必要です';

  @override
  String get invalidUserId => '無効なユーザーID';

  @override
  String get telegramBotTokenNotConfigured => '設定でTelegramボットトークンを設定してください';

  @override
  String get sentToWhatsApp => 'WhatsAppに送信しました！';

  @override
  String get sentToTelegram => 'Telegramに送信しました！';

  @override
  String get ok => 'OK';

  @override
  String get copy => 'コピー';

  @override
  String get copiedToClipboard => 'クリップボードにコピーしました';

  @override
  String get language => '言語';

  @override
  String get languageSubtitle => 'アプリの言語を変更';

  @override
  String get systemDefault => 'システムデフォルト';

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
  String get gridColumns => '列数';

  @override
  String get gridColumnsSubtitle => 'ステッカーグリッドの列数';

  @override
  String stickerLimitExceeded(int max, int skipped) {
    return 'パックの上限を超えています。最大$max個まで、$skipped個スキップされました。';
  }

  @override
  String someStickersNotProcessed(int count) {
    return '$count個のステッカーを処理できませんでした';
  }

  @override
  String get failedFiles => '失敗したファイル';

  @override
  String failedFileReason(String fileName, String reason) {
    return '$fileName: $reason';
  }

  @override
  String convertingDetail(int current, int total, String fileName) {
    return '変換中: $current/$total — $fileName';
  }

  @override
  String convertedSize(int size) {
    return '変換済み: $size KB';
  }

  @override
  String get creatingTrayIcon => 'トレイアイコン作成中...';

  @override
  String get sendingToWhatsApp => 'WhatsAppに送信中...';

  @override
  String get errorDetails => 'エラーの詳細';
}
