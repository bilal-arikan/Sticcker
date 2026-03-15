import '../../core/constants/sticker_constants.dart';

class Sticker {
  int? id;
  String uuid;
  String sourcePath;
  String? processedPath;
  String? thumbnailPath;
  MediaType mediaType;
  StickerType stickerType;
  int? width;
  int? height;
  int? fileSizeBytes;
  int? durationMs;

  // Crop/trim parameters
  double? cropX;
  double? cropY;
  double? cropWidth;
  double? cropHeight;
  int? trimStartMs;
  int? trimEndMs;

  // Metadata
  DateTime createdAt;
  DateTime? modifiedAt;
  String? emoji;

  // Pack reference
  int? packId;
  int orderInPack;

  Sticker({
    this.id,
    required this.uuid,
    required this.sourcePath,
    this.processedPath,
    this.thumbnailPath,
    required this.mediaType,
    required this.stickerType,
    this.width,
    this.height,
    this.fileSizeBytes,
    this.durationMs,
    this.cropX,
    this.cropY,
    this.cropWidth,
    this.cropHeight,
    this.trimStartMs,
    this.trimEndMs,
    required this.createdAt,
    this.modifiedAt,
    this.emoji,
    this.packId,
    this.orderInPack = 0,
  });

  bool get isProcessed => processedPath != null;
  bool get isVideo => mediaType == MediaType.video;
  bool get isGif => mediaType == MediaType.gif;
  bool get isAnimated => isVideo || isGif;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'uuid': uuid,
        'sourcePath': sourcePath,
        'processedPath': processedPath,
        'thumbnailPath': thumbnailPath,
        'mediaType': mediaType.index,
        'stickerType': stickerType.index,
        'width': width,
        'height': height,
        'fileSizeBytes': fileSizeBytes,
        'durationMs': durationMs,
        'cropX': cropX,
        'cropY': cropY,
        'cropWidth': cropWidth,
        'cropHeight': cropHeight,
        'trimStartMs': trimStartMs,
        'trimEndMs': trimEndMs,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt?.toIso8601String(),
        'emoji': emoji,
        'packId': packId,
        'orderInPack': orderInPack,
      };

  factory Sticker.fromMap(Map<String, dynamic> map) => Sticker(
        id: map['id'] as int?,
        uuid: map['uuid'] as String,
        sourcePath: map['sourcePath'] as String,
        processedPath: map['processedPath'] as String?,
        thumbnailPath: map['thumbnailPath'] as String?,
        mediaType: MediaType.values[map['mediaType'] as int],
        stickerType: StickerType.values[map['stickerType'] as int],
        width: map['width'] as int?,
        height: map['height'] as int?,
        fileSizeBytes: map['fileSizeBytes'] as int?,
        durationMs: map['durationMs'] as int?,
        cropX: map['cropX'] as double?,
        cropY: map['cropY'] as double?,
        cropWidth: map['cropWidth'] as double?,
        cropHeight: map['cropHeight'] as double?,
        trimStartMs: map['trimStartMs'] as int?,
        trimEndMs: map['trimEndMs'] as int?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        modifiedAt: map['modifiedAt'] != null
            ? DateTime.parse(map['modifiedAt'] as String)
            : null,
        emoji: map['emoji'] as String?,
        packId: map['packId'] as int?,
        orderInPack: map['orderInPack'] as int? ?? 0,
      );
}
