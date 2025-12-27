import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'music.dart';

part 'playlist.g.dart';

@JsonSerializable()
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

  factory Playlist.fromJson(Map<String, dynamic> json) => _$PlaylistFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistToJson(this);

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? coverUrl,
    String? userId,
    bool? isPublic,
    int? trackCount,
    int? totalDuration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      userId: userId ?? this.userId,
      isPublic: isPublic ?? this.isPublic,
      trackCount: trackCount ?? this.trackCount,
      totalDuration: totalDuration ?? this.totalDuration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, name, description, coverUrl, userId, isPublic,
        trackCount, totalDuration, createdAt, updatedAt,
      ];
}

@JsonSerializable()
class PlaylistTrack extends Equatable {
  final String id;
  final String playlistId;
  final String musicId;
  final int position;
  final DateTime addedAt;

  const PlaylistTrack({
    required this.id,
    required this.playlistId,
    required this.musicId,
    required this.position,
    required this.addedAt,
  });

  factory PlaylistTrack.fromJson(Map<String, dynamic> json) => _$PlaylistTrackFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistTrackToJson(this);

  @override
  List<Object?> get props => [id, playlistId, musicId, position, addedAt];
}

@JsonSerializable()
class PlaylistWithTracks {
  final Playlist playlist;
  final List<Music> tracks;

  const PlaylistWithTracks({required this.playlist, required this.tracks});

  factory PlaylistWithTracks.fromJson(Map<String, dynamic> json) => _$PlaylistWithTracksFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistWithTracksToJson(this);
}

@JsonSerializable()
class CreatePlaylistRequest {
  final String name;
  final String? description;
  final bool isPublic;

  const CreatePlaylistRequest({
    required this.name,
    this.description,
    this.isPublic = false,
  });

  factory CreatePlaylistRequest.fromJson(Map<String, dynamic> json) => _$CreatePlaylistRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePlaylistRequestToJson(this);
}

@JsonSerializable()
class UpdatePlaylistRequest {
  final String? name;
  final String? description;
  final bool? isPublic;

  const UpdatePlaylistRequest({this.name, this.description, this.isPublic});

  factory UpdatePlaylistRequest.fromJson(Map<String, dynamic> json) => _$UpdatePlaylistRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePlaylistRequestToJson(this);
}
