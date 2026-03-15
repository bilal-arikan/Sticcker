import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/sticker_constants.dart';

class StickerCache {
  static StickerCache? _instance;
  late Directory _cacheDir;
  late Directory _thumbnailDir;
  late Directory _sourcesDir;

  StickerCache._();

  static Future<StickerCache> getInstance() async {
    if (_instance != null) return _instance!;
    _instance = StickerCache._();
    await _instance!._init();
    return _instance!;
  }

  Future<void> _init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/${StickerConstants.processedCacheDir}');
    _thumbnailDir = Directory('${appDir.path}/${StickerConstants.thumbnailCacheDir}');
    _sourcesDir = Directory('${appDir.path}/${StickerConstants.sourcesDir}');
    if (!await _cacheDir.exists()) await _cacheDir.create(recursive: true);
    if (!await _thumbnailDir.exists()) await _thumbnailDir.create(recursive: true);
    if (!await _sourcesDir.exists()) await _sourcesDir.create(recursive: true);
  }

  String _generateCacheKey(String sourcePath, Map<String, dynamic>? params) {
    final input = '$sourcePath${params?.toString() ?? ''}';
    return md5.convert(utf8.encode(input)).toString();
  }

  Future<String?> getCachedPath(String sourcePath, {Map<String, dynamic>? params}) async {
    final key = _generateCacheKey(sourcePath, params);
    final cachedFile = File('${_cacheDir.path}/$key.webp');
    if (await cachedFile.exists()) {
      // Don't return 0-byte files from cache
      final size = await cachedFile.length();
      if (size > 0) return cachedFile.path;
      // Delete corrupt 0-byte cached file
      await cachedFile.delete().catchError((_) => cachedFile);
    }
    return null;
  }

  Future<String> getCachePath(String sourcePath, {String ext = 'webp', Map<String, dynamic>? params}) {
    final key = _generateCacheKey(sourcePath, params);
    return Future.value('${_cacheDir.path}/$key.$ext');
  }

  Future<String> getThumbnailPath(String sourcePath) {
    final key = _generateCacheKey(sourcePath, null);
    return Future.value('${_thumbnailDir.path}/$key.webp');
  }

  Future<int> getCacheSizeMB() async {
    int totalBytes = 0;
    await for (final entity in _cacheDir.list(recursive: true)) {
      if (entity is File) {
        totalBytes += await entity.length();
      }
    }
    await for (final entity in _thumbnailDir.list(recursive: true)) {
      if (entity is File) {
        totalBytes += await entity.length();
      }
    }
    return totalBytes ~/ (1024 * 1024);
  }

  Future<void> clearCache() async {
    if (await _cacheDir.exists()) {
      await _cacheDir.delete(recursive: true);
      await _cacheDir.create(recursive: true);
    }
    if (await _thumbnailDir.exists()) {
      await _thumbnailDir.delete(recursive: true);
      await _thumbnailDir.create(recursive: true);
    }
  }

  /// Copy source file to permanent location, returns the permanent path
  Future<String> preserveSource(String sourcePath) async {
    final ext = sourcePath.split('.').last.toLowerCase();
    final key = _generateCacheKey(sourcePath, null);
    final permanentPath = '${_sourcesDir.path}/$key.$ext';
    final permanentFile = File(permanentPath);
    if (await permanentFile.exists() && await permanentFile.length() > 0) {
      return permanentPath;
    }
    await File(sourcePath).copy(permanentPath);
    return permanentPath;
  }

  Future<void> removeCachedSticker(String sourcePath) async {
    final key = _generateCacheKey(sourcePath, null);
    final file = File('${_cacheDir.path}/$key.webp');
    final thumb = File('${_thumbnailDir.path}/$key.webp');
    if (await file.exists()) await file.delete();
    if (await thumb.exists()) await thumb.delete();
  }
}
