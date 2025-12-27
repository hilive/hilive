import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'music.dart';

part 'history.g.dart';

@JsonSerializable()
class PlayHistory extends Equatable {
  final String id;
  final String userId;
  final String musicId;
  final int playedDuration; // in seconds
  final bool completed;
  final DateTime playedAt;

  const PlayHistory({
    required this.id,
    required this.userId,
    required this.musicId,
    required this.playedDuration,
    required this.completed,
    required this.playedAt,
  });

  factory PlayHistory.fromJson(Map<String, dynamic> json) => _$PlayHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$PlayHistoryToJson(this);

  @override
  List<Object?> get props => [id, userId, musicId, playedDuration, completed, playedAt];
}

@JsonSerializable()
class PlayHistoryWithMusic extends Equatable {
  final String id;
  final String userId;
  final Music music;
  final int playedDuration;
  final bool completed;
  final DateTime playedAt;

  const PlayHistoryWithMusic({
    required this.id,
    required this.userId,
    required this.music,
    required this.playedDuration,
    required this.completed,
    required this.playedAt,
  });

  factory PlayHistoryWithMusic.fromJson(Map<String, dynamic> json) =>
      _$PlayHistoryWithMusicFromJson(json);
  Map<String, dynamic> toJson() => _$PlayHistoryWithMusicToJson(this);

  @override
  List<Object?> get props => [id, userId, music, playedDuration, completed, playedAt];
}

@JsonSerializable()
class PaginatedHistory extends Equatable {
  final List<PlayHistoryWithMusic> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedHistory({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginatedHistory.fromJson(Map<String, dynamic> json) =>
      _$PaginatedHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedHistoryToJson(this);

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [items, total, page, pageSize, totalPages];
}

@JsonSerializable()
class RecordPlayRequest extends Equatable {
  final String musicId;
  final int playedDuration;
  final bool completed;

  const RecordPlayRequest({
    required this.musicId,
    required this.playedDuration,
    this.completed = false,
  });

  factory RecordPlayRequest.fromJson(Map<String, dynamic> json) =>
      _$RecordPlayRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RecordPlayRequestToJson(this);

  @override
  List<Object?> get props => [musicId, playedDuration, completed];
}
