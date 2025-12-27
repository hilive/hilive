// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) => SearchResult(
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => Music.fromJson(e as Map<String, dynamic>))
          .toList(),
      artists: (json['artists'] as List<dynamic>)
          .map((e) => ArtistResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      albums: (json['albums'] as List<dynamic>)
          .map((e) => AlbumResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      playlists: (json['playlists'] as List<dynamic>)
          .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalTracks: (json['totalTracks'] as num).toInt(),
      totalArtists: (json['totalArtists'] as num).toInt(),
      totalAlbums: (json['totalAlbums'] as num).toInt(),
      totalPlaylists: (json['totalPlaylists'] as num).toInt(),
    );

Map<String, dynamic> _$SearchResultToJson(SearchResult instance) =>
    <String, dynamic>{
      'tracks': instance.tracks,
      'artists': instance.artists,
      'albums': instance.albums,
      'playlists': instance.playlists,
      'totalTracks': instance.totalTracks,
      'totalArtists': instance.totalArtists,
      'totalAlbums': instance.totalAlbums,
      'totalPlaylists': instance.totalPlaylists,
    };

ArtistResult _$ArtistResultFromJson(Map<String, dynamic> json) => ArtistResult(
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      trackCount: (json['trackCount'] as num).toInt(),
      albumCount: (json['albumCount'] as num).toInt(),
    );

Map<String, dynamic> _$ArtistResultToJson(ArtistResult instance) =>
    <String, dynamic>{
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'trackCount': instance.trackCount,
      'albumCount': instance.albumCount,
    };

AlbumResult _$AlbumResultFromJson(Map<String, dynamic> json) => AlbumResult(
      name: json['name'] as String,
      artist: json['artist'] as String,
      coverUrl: json['coverUrl'] as String?,
      year: (json['year'] as num?)?.toInt(),
      trackCount: (json['trackCount'] as num).toInt(),
    );

Map<String, dynamic> _$AlbumResultToJson(AlbumResult instance) =>
    <String, dynamic>{
      'name': instance.name,
      'artist': instance.artist,
      'coverUrl': instance.coverUrl,
      'year': instance.year,
      'trackCount': instance.trackCount,
    };

SearchQuery _$SearchQueryFromJson(Map<String, dynamic> json) => SearchQuery(
      query: json['query'] as String,
      type: $enumDecodeNullable(_$SearchTypeEnumMap, json['type']),
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$SearchQueryToJson(SearchQuery instance) =>
    <String, dynamic>{
      'query': instance.query,
      'type': _$SearchTypeEnumMap[instance.type],
      'page': instance.page,
      'pageSize': instance.pageSize,
    };

const _$SearchTypeEnumMap = {
  SearchType.track: 'track',
  SearchType.artist: 'artist',
  SearchType.album: 'album',
  SearchType.playlist: 'playlist',
};

SearchHistory _$SearchHistoryFromJson(Map<String, dynamic> json) =>
    SearchHistory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      query: json['query'] as String,
      searchedAt: DateTime.parse(json['searchedAt'] as String),
    );

Map<String, dynamic> _$SearchHistoryToJson(SearchHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'query': instance.query,
      'searchedAt': instance.searchedAt.toIso8601String(),
    };
