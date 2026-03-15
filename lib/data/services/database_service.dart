import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get instance async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sticcker.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sticker_packs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid TEXT NOT NULL,
            name TEXT NOT NULL,
            author TEXT DEFAULT '',
            trayIconPath TEXT,
            stickerCount INTEGER DEFAULT 0,
            telegramSetName TEXT,
            isSyncedToTelegram INTEGER DEFAULT 0,
            isSyncedToWhatsApp INTEGER DEFAULT 0,
            createdAt TEXT NOT NULL,
            modifiedAt TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE stickers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uuid TEXT NOT NULL,
            sourcePath TEXT NOT NULL,
            processedPath TEXT,
            thumbnailPath TEXT,
            mediaType INTEGER NOT NULL,
            stickerType INTEGER NOT NULL,
            width INTEGER,
            height INTEGER,
            fileSizeBytes INTEGER,
            durationMs INTEGER,
            cropX REAL,
            cropY REAL,
            cropWidth REAL,
            cropHeight REAL,
            trimStartMs INTEGER,
            trimEndMs INTEGER,
            createdAt TEXT NOT NULL,
            modifiedAt TEXT,
            emoji TEXT,
            packId INTEGER,
            orderInPack INTEGER DEFAULT 0,
            FOREIGN KEY (packId) REFERENCES sticker_packs (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('CREATE INDEX idx_stickers_packId ON stickers (packId)');
      },
    );
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
