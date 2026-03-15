import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/constants/sticker_constants.dart';

class TelegramService {
  static const _baseUrl = 'https://api.telegram.org/bot';
  final Dio _dio = Dio();
  String? _botToken;

  bool get isConfigured => _botToken != null && _botToken!.isNotEmpty;

  void configure(String token) {
    _botToken = token;
  }

  String get _apiUrl => '$_baseUrl$_botToken';

  /// Validate bot token and get bot info
  Future<Map<String, dynamic>> validateToken(String token) async {
    try {
      final response = await _dio.get('${_baseUrl}$token/getMe');
      if (response.data['ok'] == true) {
        _botToken = token;
        return response.data['result'];
      }
      throw Exception('Invalid bot token');
    } on DioException catch (e) {
      throw Exception('Failed to validate token: ${e.message}');
    }
  }

  /// Create a new sticker set
  Future<bool> createStickerSet({
    required int userId,
    required String name,
    required String title,
    required List<StickerInput> stickers,
  }) async {
    if (!isConfigured) throw Exception('Telegram bot not configured');

    final formData = FormData();
    formData.fields.addAll([
      MapEntry('user_id', userId.toString()),
      MapEntry('name', name),
      MapEntry('title', title),
    ]);

    // Add first sticker
    final firstSticker = stickers.first;
    await _addStickerToFormData(formData, firstSticker, 'stickers');

    try {
      final response = await _dio.post(
        '$_apiUrl/createNewStickerSet',
        data: formData,
      );

      if (response.data['ok'] != true) {
        throw Exception(response.data['description'] ?? 'Failed to create sticker set');
      }

      // Add remaining stickers
      for (int i = 1; i < stickers.length; i++) {
        await addStickerToSet(
          userId: userId,
          name: name,
          sticker: stickers[i],
        );
      }

      return true;
    } on DioException catch (e) {
      throw Exception('Telegram API error: ${e.response?.data?['description'] ?? e.message}');
    }
  }

  /// Add a sticker to an existing set
  Future<bool> addStickerToSet({
    required int userId,
    required String name,
    required StickerInput sticker,
  }) async {
    if (!isConfigured) throw Exception('Telegram bot not configured');

    final formData = FormData();
    formData.fields.addAll([
      MapEntry('user_id', userId.toString()),
      MapEntry('name', name),
    ]);

    await _addStickerToFormData(formData, sticker, 'sticker');

    try {
      final response = await _dio.post(
        '$_apiUrl/addStickerToSet',
        data: formData,
      );
      return response.data['ok'] == true;
    } on DioException catch (e) {
      throw Exception('Failed to add sticker: ${e.response?.data?['description'] ?? e.message}');
    }
  }

  /// Delete a sticker from a set
  Future<bool> deleteStickerFromSet(String fileId) async {
    if (!isConfigured) throw Exception('Telegram bot not configured');

    try {
      final response = await _dio.post(
        '$_apiUrl/deleteStickerFromSet',
        data: {'sticker': fileId},
      );
      return response.data['ok'] == true;
    } on DioException catch (e) {
      throw Exception('Failed to delete sticker: ${e.response?.data?['description'] ?? e.message}');
    }
  }

  /// Get sticker set info
  Future<Map<String, dynamic>> getStickerSet(String name) async {
    if (!isConfigured) throw Exception('Telegram bot not configured');

    try {
      final response = await _dio.get(
        '$_apiUrl/getStickerSet',
        queryParameters: {'name': name},
      );
      return response.data['result'];
    } on DioException catch (e) {
      throw Exception('Failed to get sticker set: ${e.response?.data?['description'] ?? e.message}');
    }
  }

  /// Get file download path from Telegram servers
  Future<String> getFilePath(String fileId) async {
    if (!isConfigured) throw Exception('Telegram bot not configured');

    final response = await _dio.get(
      '$_apiUrl/getFile',
      queryParameters: {'file_id': fileId},
    );

    if (response.data['ok'] != true) {
      throw Exception('Dosya bilgisi alinamadi: ${response.data['description']}');
    }

    return response.data['result']['file_path'] as String;
  }

  /// Download a file from Telegram servers
  Future<void> downloadFile(String filePath, String savePath) async {
    if (!isConfigured) throw Exception('Telegram bot not configured');

    final url = 'https://api.telegram.org/file/bot$_botToken/$filePath';
    await _dio.download(url, savePath);
  }

  /// Import a sticker set: downloads all stickers locally
  Future<ImportedStickerSet> importStickerSet(
    String setName,
    String saveDir, {
    void Function(int current, int total)? onProgress,
  }) async {
    if (!isConfigured) throw Exception('Telegram bot not configured');

    final setInfo = await getStickerSet(setName);
    final title = setInfo['title'] as String;
    final stickers = setInfo['stickers'] as List;

    // Create save directory
    final dir = Directory(saveDir);
    if (!await dir.exists()) await dir.create(recursive: true);

    final importedStickers = <ImportedSticker>[];

    for (int i = 0; i < stickers.length; i++) {
      onProgress?.call(i, stickers.length);

      final sticker = stickers[i] as Map<String, dynamic>;
      final fileId = sticker['file_id'] as String;
      final emoji = (sticker['emoji'] as String?) ?? '🎨';
      final isAnimated = sticker['is_animated'] == true;
      final isVideo = sticker['is_video'] == true;

      // Determine file extension
      String ext = 'webp';
      if (isVideo) ext = 'webm';
      if (isAnimated) ext = 'tgs';

      try {
        final filePath = await getFilePath(fileId);
        final savePath = '${dir.path}/sticker_$i.$ext';
        await downloadFile(filePath, savePath);

        importedStickers.add(ImportedSticker(
          localPath: savePath,
          emoji: emoji,
          isAnimated: isAnimated,
          isVideo: isVideo,
        ));
      } catch (e) {
        // Skip failed downloads, continue with rest
        continue;
      }
    }

    onProgress?.call(stickers.length, stickers.length);

    return ImportedStickerSet(
      name: setName,
      title: title,
      stickers: importedStickers,
    );
  }

  Future<void> _addStickerToFormData(
    FormData formData,
    StickerInput sticker,
    String fieldName,
  ) async {
    final file = File(sticker.filePath);
    final ext = sticker.filePath.split('.').last.toLowerCase();

    String stickerField;
    if (ext == 'webm') {
      stickerField = 'webm_sticker';
    } else if (ext == 'tgs') {
      stickerField = 'tgs_sticker';
    } else {
      stickerField = 'png_sticker';
    }

    formData.files.add(MapEntry(
      stickerField,
      await MultipartFile.fromFile(file.path, filename: 'sticker.$ext'),
    ));

    formData.fields.add(MapEntry('emojis', sticker.emoji));
  }
}

class StickerInput {
  final String filePath;
  final String emoji;
  final StickerType type;

  StickerInput({
    required this.filePath,
    this.emoji = '🎨',
    this.type = StickerType.image,
  });
}

class ImportedSticker {
  final String localPath;
  final String emoji;
  final bool isAnimated;
  final bool isVideo;

  ImportedSticker({
    required this.localPath,
    required this.emoji,
    required this.isAnimated,
    required this.isVideo,
  });
}

class ImportedStickerSet {
  final String name;
  final String title;
  final List<ImportedSticker> stickers;

  ImportedStickerSet({
    required this.name,
    required this.title,
    required this.stickers,
  });
}
