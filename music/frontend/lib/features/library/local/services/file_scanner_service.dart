import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:music_player_app/shared/models/local_music.dart';

/// 文件扫描服务
/// 负责选择和扫描本地音乐文件
class FileScannerService {
  static const _uuid = Uuid();

  /// 支持的音频格式
  static const supportedExtensions = [
    'mp3',
    'flac',
    'wav',
    'aac',
    'm4a',
    'ogg',
    'wma',
    'aiff',
  ];

  /// 选择单个或多个音乐文件
  Future<List<LocalMusic>> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedExtensions,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      final localMusics = <LocalMusic>[];
      for (final file in result.files) {
        if (file.path != null) {
          final localMusic = await _parseAudioFile(file.path!);
          if (localMusic != null) {
            localMusics.add(localMusic);
          }
        }
      }

      return localMusics;
    } catch (e) {
      return [];
    }
  }

  /// 选择文件夹并扫描其中的音乐文件
  Future<List<LocalMusic>> pickFolder() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();

      if (result == null) {
        return [];
      }

      return await scanDirectory(result);
    } catch (e) {
      return [];
    }
  }

  /// 扫描指定目录下的所有音乐文件
  Future<List<LocalMusic>> scanDirectory(String path,
      {bool recursive = true}) async {
    final localMusics = <LocalMusic>[];
    final directory = Directory(path);

    if (!await directory.exists()) {
      return [];
    }

    try {
      await for (final entity in directory.list(recursive: recursive)) {
        if (entity is File) {
          final extension = entity.path.split('.').last.toLowerCase();
          if (supportedExtensions.contains(extension)) {
            final localMusic = await _parseAudioFile(entity.path);
            if (localMusic != null) {
              localMusics.add(localMusic);
            }
          }
        }
      }
    } catch (e) {
      // 忽略扫描错误
    }

    return localMusics;
  }

  /// 解析单个音频文件（轻量化，无原生元数据依赖）
  Future<LocalMusic?> _parseAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final stat = await file.stat();
      final fileName = filePath.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();

      // 仅使用文件名作为标题，避免原生解析依赖
      final title = fileName.replaceAll('.$extension', '');

      return LocalMusic(
        id: _uuid.v4(),
        title: title,
        artist: '本地音乐',
        album: null,
        coverPath: null,
        filePath: filePath,
        duration: 0,
        genre: null,
        year: null,
        bitrate: null,
        format: extension,
        fileSize: stat.size,
        addedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }
}
