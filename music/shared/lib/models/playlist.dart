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

  String get totalDurationFormatted {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    if (hours > 0) {
      return '$hours小时$minutes分钟';
    }
    return '$minutes分钟';
  }

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
        id,
        name,
        description,
        coverUrl,
        userId,
        isPublic,
        trackCount,
        totalDuration,
        createdAt,
        updatedAt,
      ];
}

@JsonSerializable()
class PlaylistDetail extends Equatable {
  final Playlist playlist;
  final List<PlaylistTrack> tracks;

  const PlaylistDetail({
    required this.playlist,
    required this.tracks,
  });

  factory PlaylistDetail.fromJson(Map<String, dynamic> json) =>
      _$PlaylistDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistDetailToJson(this);

  @override
  List<Object?> get props => [playlist, tracks];
}

@JsonSerializable()
class PlaylistTrack extends Equatable {
  final String id;
  final String playlistId;
  final Music music;
  final int position;
  final DateTime addedAt;

  const PlaylistTrack({
    required this.id,
    required this.playlistId,
    required this.music,
    required this.position,
    required this.addedAt,
  });

  factory PlaylistTrack.fromJson(Map<String, dynamic> json) =>
      _$PlaylistTrackFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistTrackToJson(this);

  @override
  List<Object?> get props => [id, playlistId, music, position, addedAt];
}

@JsonSerializable()
class CreatePlaylistRequest extends Equatable {
  final String name;
  final String? description;
  final bool isPublic;

  const CreatePlaylistRequest({
    required this.name,
    this.description,
    this.isPublic = false,
  });

  factory CreatePlaylistRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePlaylistRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePlaylistRequestToJson(this);

  @override
  List<Object?> get props => [name, description, isPublic];
}

@JsonSerializable()
class UpdatePlaylistRequest extends Equatable {
  final String? name;
  final String? description;
  final bool? isPublic;

  const UpdatePlaylistRequest({
    this.name,
    this.description,
    this.isPublic,
  });

  factory UpdatePlaylistRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePlaylistRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePlaylistRequestToJson(this);

  @override
  List<Object?> get props => [name, description, isPublic];
}

@JsonSerializable()
class AddTrackRequest extends Equatable {
  final String musicId;
  final int? position;

  const AddTrackRequest({
    required this.musicId,
    this.position,
  });

  factory AddTrackRequest.fromJson(Map<String, dynamic> json) =>
      _$AddTrackRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddTrackRequestToJson(this);

  @override
  List<Object?> get props => [musicId, position];
}
