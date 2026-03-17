// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class SKo extends S {
  SKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Sticcker';

  @override
  String get newPack => '새 팩';

  @override
  String get importFromTelegram => 'Telegram에서 가져오기';

  @override
  String get emptyPacksTitle => '아직 스티커 팩이 없습니다';

  @override
  String get emptyPacksSubtitle => '새 팩을 만들어 시작하세요';

  @override
  String errorGeneric(String error) {
    return '오류: $error';
  }

  @override
  String get newStickerPack => '새 스티커 팩';

  @override
  String get packName => '팩 이름';

  @override
  String get packNameHint => '예: 재미있는 고양이';

  @override
  String get author => '작성자';

  @override
  String get authorHint => '이름을 입력하세요';

  @override
  String get cancel => '취소';

  @override
  String get create => '만들기';

  @override
  String get telegramBotTokenRequired => '먼저 설정에서 Telegram 봇 토큰을 입력하세요';

  @override
  String get telegramImportTitle => 'Telegram에서 가져오기';

  @override
  String get telegramImportInfo =>
      '스티커 세트 이름을 입력하세요 (예: Animals 또는 Animals_by_BotName)';

  @override
  String get setName => '세트 이름';

  @override
  String get import_ => '가져오기';

  @override
  String get importingFromTelegram => 'Telegram에서 가져오는 중';

  @override
  String get starting => '시작 중...';

  @override
  String get downloadingStickerSet => '스티커 세트 다운로드 중...';

  @override
  String downloadingProgress(int current, int total) {
    return '다운로드 중: $current/$total';
  }

  @override
  String get stickerSetEmptyOrFailed => '스티커 세트가 비어 있거나 다운로드할 수 없습니다';

  @override
  String get creatingPack => '팩 생성 중...';

  @override
  String importedSuccess(String title, int count) {
    return '\"$title\" 가져옴 (스티커 $count개)';
  }

  @override
  String get close => '닫기';

  @override
  String stickerCountInfo(int count) {
    return '스티커 $count개';
  }

  @override
  String stickerCountWithAuthor(int count, String author) {
    return '스티커 $count개 · $author';
  }

  @override
  String get pack => '팩';

  @override
  String get error => '오류';

  @override
  String get exportToWhatsApp => 'WhatsApp으로 내보내기';

  @override
  String get exportToTelegram => 'Telegram으로 내보내기';

  @override
  String get deletePack => '팩 삭제';

  @override
  String get addSticker => '스티커 추가';

  @override
  String get addStickerSubtitle => '갤러리, 파일 또는 카메라에서 추가';

  @override
  String processingProgress(int percent) {
    return '처리 중... $percent%';
  }

  @override
  String get deleteSticker => '스티커 삭제';

  @override
  String get deleteStickerConfirm => '이 스티커를 삭제하시겠습니까?';

  @override
  String get delete => '삭제';

  @override
  String get editPack => '팩 편집';

  @override
  String get save => '저장';

  @override
  String get deletePackConfirm => '이 팩과 모든 스티커가 삭제됩니다. 계속하시겠습니까?';

  @override
  String get editSticker => '스티커 편집';

  @override
  String get crop => '자르기';

  @override
  String get rotate => '회전';

  @override
  String get text => '텍스트';

  @override
  String get draw => '그리기';

  @override
  String videoDuration(String start, String end) {
    return '영상 길이: $start - $end';
  }

  @override
  String maxDurationTelegram(int seconds) {
    return '최대 $seconds초 (Telegram)';
  }

  @override
  String get emoji => '이모지: ';

  @override
  String get cropSticker => '스티커 자르기';

  @override
  String get addText => '텍스트 추가';

  @override
  String get textHint => '텍스트를 입력하세요...';

  @override
  String get add => '추가';

  @override
  String get textAdded => '텍스트 추가됨';

  @override
  String get eraser => '지우개';

  @override
  String get drawingToolComingSoon => '그리기 도구가 곧 추가됩니다';

  @override
  String get stickerSaved => '스티커 저장됨';

  @override
  String get settings => '설정';

  @override
  String get appearance => '외관';

  @override
  String get telegramIntegration => 'Telegram 연동';

  @override
  String get cache => '캐시';

  @override
  String get about => '정보';

  @override
  String get darkTheme => '다크 테마';

  @override
  String get darkThemeSubtitle => '앱을 다크 모드로 사용';

  @override
  String get botToken => '봇 토큰';

  @override
  String get botTokenHelper => '@BotFather로 봇을 만들고 토큰을 받으세요';

  @override
  String botConnected(String username) {
    return '봇 연결됨: @$username';
  }

  @override
  String get cacheSize => '캐시 크기';

  @override
  String cacheSizeUsing(int size) {
    return '$size MB 사용 중';
  }

  @override
  String get clear => '지우기';

  @override
  String get clearCache => '캐시 지우기';

  @override
  String get clearCacheConfirm => '모든 처리된 스티커가 삭제됩니다. 계속하시겠습니까?';

  @override
  String get cacheCleared => '캐시 지워짐';

  @override
  String get openSourceLicenses => '오픈소스 라이선스';

  @override
  String get stickerSetName => '스티커 세트 이름';

  @override
  String get stickerSetNameHelper => '영문자, 숫자, 밑줄만 사용 가능';

  @override
  String get telegramUserId => 'Telegram 사용자 ID';

  @override
  String get telegramUserIdHelper => '@userinfobot으로 확인할 수 있습니다';

  @override
  String get sendToWhatsApp => 'WhatsApp으로 보내기';

  @override
  String get sendToTelegram => 'Telegram으로 보내기';

  @override
  String get preparingStickers => '스티커 준비 중...';

  @override
  String convertingProgress(int current, int total) {
    return '변환 중: $current/$total';
  }

  @override
  String get sendingToTelegram => 'Telegram으로 보내는 중...';

  @override
  String get packNotFound => '팩을 찾을 수 없습니다';

  @override
  String get setNameAndUserIdRequired => '세트 이름과 사용자 ID가 필요합니다';

  @override
  String get invalidUserId => '유효하지 않은 사용자 ID';

  @override
  String get telegramBotTokenNotConfigured => '설정에서 Telegram 봇 토큰을 구성해야 합니다';

  @override
  String get sentToWhatsApp => 'WhatsApp으로 전송됨!';

  @override
  String get sentToTelegram => 'Telegram으로 전송됨!';

  @override
  String get ok => '확인';

  @override
  String get copy => '복사';

  @override
  String get copiedToClipboard => '클립보드에 복사됨';

  @override
  String get language => '언어';

  @override
  String get languageSubtitle => '앱 언어 변경';

  @override
  String get systemDefault => '시스템 기본값';

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
  String get gridColumns => '열 수';

  @override
  String get gridColumnsSubtitle => '스티커 그리드의 열 수';

  @override
  String stickerLimitExceeded(int max, int skipped) {
    return '팩 한도 초과. 최대 $max개 허용, $skipped개 건너뜀.';
  }

  @override
  String someStickersNotProcessed(int count) {
    return '$count개의 스티커를 처리할 수 없습니다';
  }

  @override
  String get failedFiles => '실패한 파일';

  @override
  String failedFileReason(String fileName, String reason) {
    return '$fileName: $reason';
  }

  @override
  String convertingDetail(int current, int total, String fileName) {
    return '변환 중: $current/$total — $fileName';
  }

  @override
  String convertedSize(int size) {
    return '변환됨: $size KB';
  }

  @override
  String get creatingTrayIcon => '트레이 아이콘 생성 중...';

  @override
  String get sendingToWhatsApp => 'WhatsApp으로 보내는 중...';

  @override
  String get errorDetails => '오류 세부정보';
}
