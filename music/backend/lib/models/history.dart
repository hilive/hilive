import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'music.dart';

part 'history.g.dart';

@JsonSerializable()
class PlayHistory extends Equatable {
  final String id;
  final String userId;
  final String musicId;
  final int playedDuration;
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
class PlayHistoryWithMusic {
  final PlayHistory history;
  final Music music;

  const PlayHistoryWithMusic({required this.history, required this.music});

  factory PlayHistoryWithMusic.fromJson(Map<String, dynamic> json) => _$PlayHistoryWithMusicFromJson(json);
  Map<String, dynamic> toJson() => _$PlayHistoryWithMusicToJson(this);
}

@JsonSerializable()
class RecordPlayRequest {
  final String musicId;
  final int playedDuration;
  final bool completed;

  const RecordPlayRequest({
    required this.musicId,
    required this.playedDuration,
    this.completed = false,
  });

  factory RecordPlayRequest.fromJson(Map<String, dynamic> json) => _$RecordPlayRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RecordPlayRequestToJson(this);
}
