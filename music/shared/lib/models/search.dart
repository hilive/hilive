import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'music.dart';
import 'playlist.dart';

part 'search.g.dart';

@JsonSerializable()
class SearchResult extends Equatable {
  final List<Music> tracks;
  final List<ArtistResult> artists;
  final List<AlbumResult> albums;
  final List<Playlist> playlists;
  final int totalTracks;
  final int totalArtists;
  final int totalAlbums;
  final int totalPlaylists;

  const SearchResult({
    required this.tracks,
    required this.artists,
    required this.albums,
    required this.playlists,
    required this.totalTracks,
    required this.totalArtists,
    required this.totalAlbums,
    required this.totalPlaylists,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$SearchResultToJson(this);

  bool get isEmpty =>
      tracks.isEmpty && artists.isEmpty && albums.isEmpty && playlists.isEmpty;

  @override
  List<Object?> get props => [
        tracks,
        artists,
        albums,
        playlists,
        totalTracks,
        totalArtists,
        totalAlbums,
        totalPlaylists,
      ];
}

@JsonSerializable()
class ArtistResult extends Equatable {
  final String name;
  final String? avatarUrl;
  final int trackCount;
  final int albumCount;

  const ArtistResult({
    required this.name,
    this.avatarUrl,
    required this.trackCount,
    required this.albumCount,
  });

  factory ArtistResult.fromJson(Map<String, dynamic> json) =>
      _$ArtistResultFromJson(json);
  Map<String, dynamic> toJson() => _$ArtistResultToJson(this);

  @override
  List<Object?> get props => [name, avatarUrl, trackCount, albumCount];
}

@JsonSerializable()
class AlbumResult extends Equatable {
  final String name;
  final String artist;
  final String? coverUrl;
  final int? year;
  final int trackCount;

  const AlbumResult({
    required this.name,
    required this.artist,
    this.coverUrl,
    this.year,
    required this.trackCount,
  });

  factory AlbumResult.fromJson(Map<String, dynamic> json) =>
      _$AlbumResultFromJson(json);
  Map<String, dynamic> toJson() => _$AlbumResultToJson(this);

  @override
  List<Object?> get props => [name, artist, coverUrl, year, trackCount];
}

@JsonSerializable()
class SearchQuery extends Equatable {
  final String query;
  final SearchType? type;
  final int page;
  final int pageSize;

  const SearchQuery({
    required this.query,
    this.type,
    this.page = 1,
    this.pageSize = 20,
  });

  factory SearchQuery.fromJson(Map<String, dynamic> json) =>
      _$SearchQueryFromJson(json);
  Map<String, dynamic> toJson() => _$SearchQueryToJson(this);

  @override
  List<Object?> get props => [query, type, page, pageSize];
}

enum SearchType {
  @JsonValue('track')
  track,
  @JsonValue('artist')
  artist,
  @JsonValue('album')
  album,
  @JsonValue('playlist')
  playlist,
}

@JsonSerializable()
class SearchHistory extends Equatable {
  final String id;
  final String userId;
  final String query;
  final DateTime searchedAt;

  const SearchHistory({
    required this.id,
    required this.userId,
    required this.query,
    required this.searchedAt,
  });

  factory SearchHistory.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$SearchHistoryToJson(this);

  @override
  List<Object?> get props => [id, userId, query, searchedAt];
}
