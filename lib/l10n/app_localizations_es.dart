// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Sticcker';

  @override
  String get newPack => 'Nuevo paquete';

  @override
  String get importFromTelegram => 'Importar desde Telegram';

  @override
  String get emptyPacksTitle => 'Aún no hay paquetes de stickers';

  @override
  String get emptyPacksSubtitle => 'Comienza creando un nuevo paquete';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get newStickerPack => 'Nuevo paquete de stickers';

  @override
  String get packName => 'Nombre del paquete';

  @override
  String get packNameHint => 'ej. Gatos divertidos';

  @override
  String get author => 'Autor';

  @override
  String get authorHint => 'Tu nombre';

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Crear';

  @override
  String get telegramBotTokenRequired =>
      'Primero ingresa el token del bot de Telegram en Ajustes';

  @override
  String get telegramImportTitle => 'Importar desde Telegram';

  @override
  String get telegramImportInfo =>
      'Ingresa el nombre del set de stickers (ej. Animals o Animals_by_BotName)';

  @override
  String get setName => 'Nombre del set';

  @override
  String get import_ => 'Importar';

  @override
  String get importingFromTelegram => 'Importando desde Telegram';

  @override
  String get starting => 'Iniciando...';

  @override
  String get downloadingStickerSet => 'Descargando set de stickers...';

  @override
  String downloadingProgress(int current, int total) {
    return 'Descargando: $current/$total';
  }

  @override
  String get stickerSetEmptyOrFailed =>
      'El set de stickers está vacío o no se pudo descargar';

  @override
  String get creatingPack => 'Creando paquete...';

  @override
  String importedSuccess(String title, int count) {
    return '\"$title\" importado ($count stickers)';
  }

  @override
  String get close => 'Cerrar';

  @override
  String stickerCountInfo(int count) {
    return '$count stickers';
  }

  @override
  String stickerCountWithAuthor(int count, String author) {
    return '$count stickers · $author';
  }

  @override
  String get pack => 'Paquete';

  @override
  String get error => 'Error';

  @override
  String get exportToWhatsApp => 'Exportar a WhatsApp';

  @override
  String get exportToTelegram => 'Exportar a Telegram';

  @override
  String get deletePack => 'Eliminar paquete';

  @override
  String get addSticker => 'Agregar sticker';

  @override
  String get addStickerSubtitle => 'Agregar desde galería, archivos o cámara';

  @override
  String processingProgress(int percent) {
    return 'Procesando... $percent%';
  }

  @override
  String get deleteSticker => 'Eliminar sticker';

  @override
  String get deleteStickerConfirm => '¿Eliminar este sticker?';

  @override
  String get delete => 'Eliminar';

  @override
  String get editPack => 'Editar paquete';

  @override
  String get save => 'Guardar';

  @override
  String get deletePackConfirm =>
      'Este paquete y todos sus stickers serán eliminados. ¿Estás seguro?';

  @override
  String get editSticker => 'Editar sticker';

  @override
  String get crop => 'Recortar';

  @override
  String get rotate => 'Rotar';

  @override
  String get text => 'Texto';

  @override
  String get draw => 'Dibujar';

  @override
  String videoDuration(String start, String end) {
    return 'Duración del video: $start - $end';
  }

  @override
  String maxDurationTelegram(int seconds) {
    return 'Máx. $seconds segundos (Telegram)';
  }

  @override
  String get emoji => 'Emoji: ';

  @override
  String get cropSticker => 'Recortar sticker';

  @override
  String get addText => 'Agregar texto';

  @override
  String get textHint => 'Escribe tu texto...';

  @override
  String get add => 'Agregar';

  @override
  String get textAdded => 'Texto agregado';

  @override
  String get eraser => 'Borrador';

  @override
  String get drawingToolComingSoon => 'Herramienta de dibujo próximamente';

  @override
  String get stickerSaved => 'Sticker guardado';

  @override
  String get settings => 'Ajustes';

  @override
  String get appearance => 'Apariencia';

  @override
  String get telegramIntegration => 'Integración con Telegram';

  @override
  String get cache => 'Caché';

  @override
  String get about => 'Acerca de';

  @override
  String get darkTheme => 'Tema oscuro';

  @override
  String get darkThemeSubtitle => 'Usar la app en modo oscuro';

  @override
  String get botToken => 'Token del bot';

  @override
  String get botTokenHelper => 'Crea un bot con @BotFather y obtén el token';

  @override
  String botConnected(String username) {
    return 'Bot conectado: @$username';
  }

  @override
  String get cacheSize => 'Tamaño de caché';

  @override
  String cacheSizeUsing(int size) {
    return 'Usando $size MB';
  }

  @override
  String get clear => 'Limpiar';

  @override
  String get clearCache => 'Limpiar caché';

  @override
  String get clearCacheConfirm =>
      'Todos los stickers procesados serán eliminados. ¿Estás seguro?';

  @override
  String get cacheCleared => 'Caché limpiada';

  @override
  String get openSourceLicenses => 'Licencias de código abierto';

  @override
  String get stickerSetName => 'Nombre del set de stickers';

  @override
  String get stickerSetNameHelper => 'Solo letras, números y guiones bajos';

  @override
  String get telegramUserId => 'ID de usuario de Telegram';

  @override
  String get telegramUserIdHelper => 'Puedes encontrarlo con @userinfobot';

  @override
  String get sendToWhatsApp => 'Enviar a WhatsApp';

  @override
  String get sendToTelegram => 'Enviar a Telegram';

  @override
  String get preparingStickers => 'Preparando stickers...';

  @override
  String convertingProgress(int current, int total) {
    return 'Convirtiendo: $current/$total';
  }

  @override
  String get sendingToTelegram => 'Enviando a Telegram...';

  @override
  String get packNotFound => 'Paquete no encontrado';

  @override
  String get setNameAndUserIdRequired =>
      'Se requiere nombre del set e ID de usuario';

  @override
  String get invalidUserId => 'ID de usuario no válido';

  @override
  String get telegramBotTokenNotConfigured =>
      'El token del bot de Telegram debe configurarse en ajustes';

  @override
  String get sentToWhatsApp => '¡Enviado a WhatsApp!';

  @override
  String get sentToTelegram => '¡Enviado a Telegram!';

  @override
  String get ok => 'Aceptar';

  @override
  String get copy => 'Copiar';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle => 'Cambiar idioma de la app';

  @override
  String get systemDefault => 'Predeterminado del sistema';

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
  String get gridColumns => 'Columnas';

  @override
  String get gridColumnsSubtitle => 'Número de columnas en la cuadrícula';

  @override
  String stickerLimitExceeded(int max, int skipped) {
    return 'Límite del paquete excedido. Máximo $max stickers, $skipped omitidos.';
  }

  @override
  String someStickersNotProcessed(int count) {
    return '$count stickers no se pudieron procesar';
  }

  @override
  String get failedFiles => 'Archivos fallidos';

  @override
  String failedFileReason(String fileName, String reason) {
    return '$fileName: $reason';
  }

  @override
  String convertingDetail(int current, int total, String fileName) {
    return 'Convirtiendo: $current/$total — $fileName';
  }

  @override
  String convertedSize(int size) {
    return 'Convertido: $size KB';
  }

  @override
  String get creatingTrayIcon => 'Creando icono de bandeja...';

  @override
  String get sendingToWhatsApp => 'Enviando a WhatsApp...';

  @override
  String get errorDetails => 'Detalles del error';
}
