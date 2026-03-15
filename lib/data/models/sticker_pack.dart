class StickerPack {
  int? id;
  String uuid;
  String name;
  String author;
  String? trayIconPath;
  int stickerCount;

  // Telegram integration
  String? telegramSetName;
  bool isSyncedToTelegram;

  // WhatsApp integration
  bool isSyncedToWhatsApp;

  // Metadata
  DateTime createdAt;
  DateTime? modifiedAt;

  StickerPack({
    this.id,
    required this.uuid,
    required this.name,
    this.author = '',
    this.trayIconPath,
    this.stickerCount = 0,
    this.telegramSetName,
    this.isSyncedToTelegram = false,
    this.isSyncedToWhatsApp = false,
    required this.createdAt,
    this.modifiedAt,
  });

  bool get canExportToWhatsApp => stickerCount >= 3 && stickerCount <= 30;
  bool get canExportToTelegram => stickerCount >= 1 && stickerCount <= 120;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'uuid': uuid,
        'name': name,
        'author': author,
        'trayIconPath': trayIconPath,
        'stickerCount': stickerCount,
        'telegramSetName': telegramSetName,
        'isSyncedToTelegram': isSyncedToTelegram ? 1 : 0,
        'isSyncedToWhatsApp': isSyncedToWhatsApp ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt?.toIso8601String(),
      };

  factory StickerPack.fromMap(Map<String, dynamic> map) => StickerPack(
        id: map['id'] as int?,
        uuid: map['uuid'] as String,
        name: map['name'] as String,
        author: map['author'] as String? ?? '',
        trayIconPath: map['trayIconPath'] as String?,
        stickerCount: map['stickerCount'] as int? ?? 0,
        telegramSetName: map['telegramSetName'] as String?,
        isSyncedToTelegram: (map['isSyncedToTelegram'] as int? ?? 0) == 1,
        isSyncedToWhatsApp: (map['isSyncedToWhatsApp'] as int? ?? 0) == 1,
        createdAt: DateTime.parse(map['createdAt'] as String),
        modifiedAt: map['modifiedAt'] != null
            ? DateTime.parse(map['modifiedAt'] as String)
            : null,
      );
}
