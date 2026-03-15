import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/sticker.dart';
import '../services/database_service.dart';
import '../../core/constants/sticker_constants.dart';

class StickerRepository {
  Future<Database> get _db => DatabaseService.instance;

  Future<List<Sticker>> getStickersForPack(int packId) async {
    final db = await _db;
    final maps = await db.query(
      'stickers',
      where: 'packId = ?',
      whereArgs: [packId],
      orderBy: 'orderInPack ASC',
    );
    return maps.map(Sticker.fromMap).toList();
  }

  Future<Sticker?> getStickerById(int id) async {
    final db = await _db;
    final maps = await db.query('stickers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Sticker.fromMap(maps.first);
  }

  Future<Sticker> createSticker({
    required String sourcePath,
    required MediaType mediaType,
    required int packId,
  }) async {
    final db = await _db;

    final stickerType = mediaType == MediaType.image
        ? StickerType.image
        : StickerType.video;

    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM stickers WHERE packId = ?',
      [packId],
    );
    final currentCount = Sqflite.firstIntValue(countResult) ?? 0;

    final sticker = Sticker(
      uuid: const Uuid().v4(),
      sourcePath: sourcePath,
      mediaType: mediaType,
      stickerType: stickerType,
      packId: packId,
      orderInPack: currentCount,
      createdAt: DateTime.now(),
    );

    final id = await db.insert('stickers', sticker.toMap());
    sticker.id = id;
    return sticker;
  }

  Future<Sticker> insertSticker(Sticker sticker) async {
    final db = await _db;
    final id = await db.insert('stickers', sticker.toMap());
    sticker.id = id;
    return sticker;
  }

  Future<void> updateSticker(Sticker sticker) async {
    final db = await _db;
    sticker.modifiedAt = DateTime.now();
    await db.update('stickers', sticker.toMap(), where: 'id = ?', whereArgs: [sticker.id]);
  }

  Future<void> deleteSticker(int id) async {
    final db = await _db;
    await db.delete('stickers', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> moveStickerToPack(int stickerId, int targetPackId) async {
    final db = await _db;
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM stickers WHERE packId = ?',
      [targetPackId],
    );
    final newOrder = Sqflite.firstIntValue(countResult) ?? 0;

    await db.update(
      'stickers',
      {
        'packId': targetPackId,
        'orderInPack': newOrder,
        'modifiedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [stickerId],
    );
  }

  Future<void> reorderStickers(int packId, List<int> stickerIds) async {
    final db = await _db;
    final batch = db.batch();
    for (int i = 0; i < stickerIds.length; i++) {
      batch.update(
        'stickers',
        {'orderInPack': i},
        where: 'id = ?',
        whereArgs: [stickerIds[i]],
      );
    }
    await batch.commit(noResult: true);
  }
}
