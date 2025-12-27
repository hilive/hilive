import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'music.g.dart';

@JsonSerializable()
class Music extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? coverUrl;
  final String audioUrl;
  final int duration; // in seconds
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

  factory Music.fromJson(Map<String, dynamic> json) => _$MusicFromJson(json);
  Map<String, dynamic> toJson() => _$MusicToJson(this);

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Music copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? coverUrl,
    String? audioUrl,
    int? duration,
    int? trackNumber,
    String? genre,
    int? year,
    int? bitrate,
    String? format,
    int? fileSize,
    String? uploaderId,
    bool? isPublic,
    int? playCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Music(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      coverUrl: coverUrl ?? this.coverUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      trackNumber: trackNumber ?? this.trackNumber,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      bitrate: bitrate ?? this.bitrate,
      format: format ?? this.format,
      fileSize: fileSize ?? this.fileSize,
      uploaderId: uploaderId ?? this.uploaderId,
      isPublic: isPublic ?? this.isPublic,
      playCount: playCount ?? this.playCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        album,
        coverUrl,
        audioUrl,
        duration,
        trackNumber,
        genre,
        year,
        bitrate,
        format,
        fileSize,
        uploaderId,
        isPublic,
        playCount,
        createdAt,
        updatedAt,
      ];
}

@JsonSerializable()
class MusicUploadRequest extends Equatable {
  final String title;
  final String artist;
  final String? album;
  final String? genre;
  final int? year;
  final bool isPublic;

  const MusicUploadRequest({
    required this.title,
    required this.artist,
    this.album,
    this.genre,
    this.year,
    this.isPublic = true,
  });

  factory MusicUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$MusicUploadRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MusicUploadRequestToJson(this);

  @override
  List<Object?> get props => [title, artist, album, genre, year, isPublic];
}

@JsonSerializable()
class PaginatedMusic extends Equatable {
  final List<Music> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedMusic({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginatedMusic.fromJson(Map<String, dynamic> json) =>
      _$PaginatedMusicFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedMusicToJson(this);

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [items, total, page, pageSize, totalPages];
}
