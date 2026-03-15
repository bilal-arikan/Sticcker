import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/sticker_pack.dart';
import '../services/database_service.dart';

class PackRepository {
  Future<Database> get _db => DatabaseService.instance;

  Future<List<StickerPack>> getAllPacks() async {
    final db = await _db;
    final maps = await db.query('sticker_packs', orderBy: 'createdAt DESC');
    return maps.map(StickerPack.fromMap).toList();
  }

  Future<StickerPack?> getPackById(int id) async {
    final db = await _db;
    final maps = await db.query('sticker_packs', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return StickerPack.fromMap(maps.first);
  }

  Future<StickerPack> createPack({required String name, String author = ''}) async {
    final db = await _db;
    final pack = StickerPack(
      uuid: const Uuid().v4(),
      name: name,
      author: author,
      createdAt: DateTime.now(),
    );
    final id = await db.insert('sticker_packs', pack.toMap());
    pack.id = id;
    return pack;
  }

  Future<void> updatePack(StickerPack pack) async {
    final db = await _db;
    pack.modifiedAt = DateTime.now();
    await db.update('sticker_packs', pack.toMap(), where: 'id = ?', whereArgs: [pack.id]);
  }

  Future<void> deletePack(int id) async {
    final db = await _db;
    await db.delete('stickers', where: 'packId = ?', whereArgs: [id]);
    await db.delete('sticker_packs', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateStickerCount(int packId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM stickers WHERE packId = ?',
      [packId],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    await db.update(
      'sticker_packs',
      {'stickerCount': count, 'modifiedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [packId],
    );
  }
}
