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
class FavoriteWithMusic {
  final Favorite favorite;
  final Music music;

  const FavoriteWithMusic({required this.favorite, required this.music});

  factory FavoriteWithMusic.fromJson(Map<String, dynamic> json) => _$FavoriteWithMusicFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteWithMusicToJson(this);
}
