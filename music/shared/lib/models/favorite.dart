import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'music.dart';

part 'favorite.g.dart';

@JsonSerializable()
class Favorite extends Equatable {
  final String id;
  final String userId;
  final String musicId;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.userId,
    required this.musicId,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => _$FavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteToJson(this);

  @override
  List<Object?> get props => [id, userId, musicId, createdAt];
}

@JsonSerializable()
class FavoriteWithMusic extends Equatable {
  final String id;
  final String userId;
  final Music music;
  final DateTime createdAt;

  const FavoriteWithMusic({
    required this.id,
    required this.userId,
    required this.music,
    required this.createdAt,
  });

  factory FavoriteWithMusic.fromJson(Map<String, dynamic> json) =>
      _$FavoriteWithMusicFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteWithMusicToJson(this);

  @override
  List<Object?> get props => [id, userId, music, createdAt];
}

@JsonSerializable()
class PaginatedFavorites extends Equatable {
  final List<FavoriteWithMusic> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedFavorites({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginatedFavorites.fromJson(Map<String, dynamic> json) =>
      _$PaginatedFavoritesFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedFavoritesToJson(this);

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [items, total, page, pageSize, totalPages];
}
