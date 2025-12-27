// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Favorite _$FavoriteFromJson(Map<String, dynamic> json) => Favorite(
      id: json['id'] as String,
      userId: json['userId'] as String,
      musicId: json['musicId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FavoriteToJson(Favorite instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'musicId': instance.musicId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

FavoriteWithMusic _$FavoriteWithMusicFromJson(Map<String, dynamic> json) =>
    FavoriteWithMusic(
      favorite: Favorite.fromJson(json['favorite'] as Map<String, dynamic>),
      music: Music.fromJson(json['music'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FavoriteWithMusicToJson(FavoriteWithMusic instance) =>
    <String, dynamic>{
      'favorite': instance.favorite,
      'music': instance.music,
    };
