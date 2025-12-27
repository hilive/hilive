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
      id: json['id'] as String,
      userId: json['userId'] as String,
      music: Music.fromJson(json['music'] as Map<String, dynamic>),
      playedDuration: (json['playedDuration'] as num).toInt(),
      completed: json['completed'] as bool,
      playedAt: DateTime.parse(json['playedAt'] as String),
    );

Map<String, dynamic> _$PlayHistoryWithMusicToJson(
        PlayHistoryWithMusic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'music': instance.music,
      'playedDuration': instance.playedDuration,
      'completed': instance.completed,
      'playedAt': instance.playedAt.toIso8601String(),
    };

PaginatedHistory _$PaginatedHistoryFromJson(Map<String, dynamic> json) =>
    PaginatedHistory(
      items: (json['items'] as List<dynamic>)
          .map((e) => PlayHistoryWithMusic.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$PaginatedHistoryToJson(PaginatedHistory instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
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
