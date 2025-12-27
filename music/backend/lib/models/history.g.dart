// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayHistory _$PlayHistoryFromJson(Map<String, dynamic> json) => PlayHistory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      musicId: json['musicId'] as String,
      playedDuration: (json['playedDuration'] as num).toInt(),
      completed: json['completed'] as bool,
      playedAt: DateTime.parse(json['playedAt'] as String),
    );

Map<String, dynamic> _$PlayHistoryToJson(PlayHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'musicId': instance.musicId,
      'playedDuration': instance.playedDuration,
      'completed': instance.completed,
      'playedAt': instance.playedAt.toIso8601String(),
    };

PlayHistoryWithMusic _$PlayHistoryWithMusicFromJson(
        Map<String, dynamic> json) =>
    PlayHistoryWithMusic(
      history: PlayHistory.fromJson(json['history'] as Map<String, dynamic>),
      music: Music.fromJson(json['music'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlayHistoryWithMusicToJson(
        PlayHistoryWithMusic instance) =>
    <String, dynamic>{
      'history': instance.history,
      'music': instance.music,
    };

RecordPlayRequest _$RecordPlayRequestFromJson(Map<String, dynamic> json) =>
    RecordPlayRequest(
      musicId: json['musicId'] as String,
      playedDuration: (json['playedDuration'] as num).toInt(),
      completed: json['completed'] as bool? ?? false,
    );

Map<String, dynamic> _$RecordPlayRequestToJson(RecordPlayRequest instance) =>
    <String, dynamic>{
      'musicId': instance.musicId,
      'playedDuration': instance.playedDuration,
      'completed': instance.completed,
    };
