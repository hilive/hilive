import 'package:equatable/equatable.dart';
import 'music.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final String userId;
  final bool isPublic;
  final int trackCount;
  final int totalDuration;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    required this.userId,
    this.isPublic = false,
    this.trackCount = 0,
    this.totalDuration = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverUrl: json['coverUrl'] as String?,
      userId: json['userId'] as String,
      isPublic: json['isPublic'] as bool? ?? false,
      trackCount: json['trackCount'] as int? ?? 0,
      totalDuration: json['totalDuration'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'coverUrl': coverUrl,
    'userId': userId,
    'isPublic': isPublic,
    'trackCount': trackCount,
    'totalDuration': totalDuration,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  String get totalDurationFormatted {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours小时$minutes分钟';
    }
    return '$minutes分钟';
  }

  @override
  List<Object?> get props => [
    id, name, description, coverUrl, userId, isPublic,
    trackCount, totalDuration, createdAt, updatedAt,
  ];
}

class PlaylistWithTracks extends Equatable {
  final Playlist playlist;
  final List<Music> tracks;

  const PlaylistWithTracks({
    required this.playlist,
    required this.tracks,
  });

  factory PlaylistWithTracks.fromJson(Map<String, dynamic> json) {
    return PlaylistWithTracks(
      playlist: Playlist.fromJson(json['playlist'] as Map<String, dynamic>),
      tracks: (json['tracks'] as List)
          .map((e) => Music.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [playlist, tracks];
}
