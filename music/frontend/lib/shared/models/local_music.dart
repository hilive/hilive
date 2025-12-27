import 'package:equatable/equatable.dart';
import 'music.dart';

/// 本地音乐模型
/// 用于管理设备本地的音乐文件
class LocalMusic extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? coverPath; // 本地封面路径（可从元数据提取）
  final String filePath; // 本地文件绝对路径
  final int duration; // 时长（秒）
  final String? genre;
  final int? year;
  final int? bitrate;
  final String format; // mp3, flac, wav 等
  final int fileSize;
  final DateTime addedAt; // 添加到本地库的时间
  final DateTime? lastPlayedAt;
  final int playCount;

  const LocalMusic({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.coverPath,
    required this.filePath,
    required this.duration,
    this.genre,
    this.year,
    this.bitrate,
    required this.format,
    required this.fileSize,
    required this.addedAt,
    this.lastPlayedAt,
    this.playCount = 0,
  });

  /// 转换为 Music 以复用现有播放器
  Music toMusic() {
    return Music(
      id: id,
      title: title,
      artist: artist,
      album: album,
      coverUrl: coverPath,
      audioUrl: filePath, // 直接使用文件路径，播放器会处理
      duration: duration,
      genre: genre,
      year: year,
      bitrate: bitrate,
      format: format,
      fileSize: fileSize,
      uploaderId: 'local',
      isPublic: false,
      playCount: playCount,
      createdAt: addedAt,
    );
  }

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// 从 JSON 反序列化
  factory LocalMusic.fromJson(Map<String, dynamic> json) {
    return LocalMusic(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      coverPath: json['coverPath'] as String?,
      filePath: json['filePath'] as String,
      duration: json['duration'] as int,
      genre: json['genre'] as String?,
      year: json['year'] as int?,
      bitrate: json['bitrate'] as int?,
      format: json['format'] as String,
      fileSize: json['fileSize'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.parse(json['lastPlayedAt'] as String)
          : null,
      playCount: json['playCount'] as int? ?? 0,
    );
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'coverPath': coverPath,
        'filePath': filePath,
        'duration': duration,
        'genre': genre,
        'year': year,
        'bitrate': bitrate,
        'format': format,
        'fileSize': fileSize,
        'addedAt': addedAt.toIso8601String(),
        'lastPlayedAt': lastPlayedAt?.toIso8601String(),
        'playCount': playCount,
      };

  /// 创建更新后的副本
  LocalMusic copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? coverPath,
    String? filePath,
    int? duration,
    String? genre,
    int? year,
    int? bitrate,
    String? format,
    int? fileSize,
    DateTime? addedAt,
    DateTime? lastPlayedAt,
    int? playCount,
  }) {
    return LocalMusic(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      coverPath: coverPath ?? this.coverPath,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      bitrate: bitrate ?? this.bitrate,
      format: format ?? this.format,
      fileSize: fileSize ?? this.fileSize,
      addedAt: addedAt ?? this.addedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      playCount: playCount ?? this.playCount,
    );
  }

  @override
  List<Object?> get props => [id, filePath];
}
