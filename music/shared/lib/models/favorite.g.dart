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
      id: json['id'] as String,
      userId: json['userId'] as String,
      music: Music.fromJson(json['music'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FavoriteWithMusicToJson(FavoriteWithMusic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'music': instance.music,
      'createdAt': instance.createdAt.toIso8601String(),
    };

PaginatedFavorites _$PaginatedFavoritesFromJson(Map<String, dynamic> json) =>
    PaginatedFavorites(
      items: (json['items'] as List<dynamic>)
          .map((e) => FavoriteWithMusic.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$PaginatedFavoritesToJson(PaginatedFavorites instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
    };
