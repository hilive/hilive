import 'package:equatable/equatable.dart';

class Music extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? coverUrl;
  final String audioUrl;
  final int duration;
  final int? trackNumber;
  final String? genre;
  final int? year;
  final int? bitrate;
  final String? format;
  final int fileSize;
  final String uploaderId;
  final bool isPublic;
  final int playCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Music({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.coverUrl,
    required this.audioUrl,
    required this.duration,
    this.trackNumber,
    this.genre,
    this.year,
    this.bitrate,
    this.format,
    required this.fileSize,
    required this.uploaderId,
    this.isPublic = true,
    this.playCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      coverUrl: json['coverUrl'] as String?,
      audioUrl: json['audioUrl'] as String,
      duration: json['duration'] as int,
      trackNumber: json['trackNumber'] as int?,
      genre: json['genre'] as String?,
      year: json['year'] as int?,
      bitrate: json['bitrate'] as int?,
      format: json['format'] as String?,
      fileSize: json['fileSize'] as int,
      uploaderId: json['uploaderId'] as String,
      isPublic: json['isPublic'] as bool? ?? true,
      playCount: json['playCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'coverUrl': coverUrl,
    'audioUrl': audioUrl,
    'duration': duration,
    'trackNumber': trackNumber,
    'genre': genre,
    'year': year,
    'bitrate': bitrate,
    'format': format,
    'fileSize': fileSize,
    'uploaderId': uploaderId,
    'isPublic': isPublic,
    'playCount': playCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    id, title, artist, album, coverUrl, audioUrl, duration,
    trackNumber, genre, year, bitrate, format, fileSize,
    uploaderId, isPublic, playCount, createdAt, updatedAt,
  ];
}

class PaginatedMusic extends Equatable {
  final List<Music> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasMore;

  const PaginatedMusic({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasMore,
  });

  factory PaginatedMusic.fromJson(Map<String, dynamic> json) {
    return PaginatedMusic(
      items: (json['items'] as List)
          .map((e) => Music.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalPages: json['totalPages'] as int,
      hasMore: json['hasMore'] as bool,
    );
  }

  @override
  List<Object?> get props => [items, total, page, pageSize, totalPages, hasMore];
}
