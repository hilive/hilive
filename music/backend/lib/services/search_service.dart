import '../models/music.dart';
import '../models/playlist.dart';
import '../repositories/music_repository.dart';
import '../repositories/playlist_repository.dart';

class SearchResult {
  final List<Music> tracks;
  final List<ArtistResult> artists;
  final List<AlbumResult> albums;
  final List<Playlist> playlists;

  SearchResult({
    required this.tracks,
    required this.artists,
    required this.albums,
    required this.playlists,
  });

  Map<String, dynamic> toJson() => {
    'tracks': tracks.map((t) => t.toJson()).toList(),
    'artists': artists.map((a) => a.toJson()).toList(),
    'albums': albums.map((a) => a.toJson()).toList(),
    'playlists': playlists.map((p) => p.toJson()).toList(),
    'totalTracks': tracks.length,
    'totalArtists': artists.length,
    'totalAlbums': albums.length,
    'totalPlaylists': playlists.length,
  };
}

class ArtistResult {
  final String name;
  final String? avatarUrl;
  final int trackCount;

  ArtistResult({
    required this.name,
    this.avatarUrl,
    required this.trackCount,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'avatarUrl': avatarUrl,
    'trackCount': trackCount,
  };
}

class AlbumResult {
  final String name;
  final String artist;
  final String? coverUrl;
  final int? year;
  final int trackCount;

  AlbumResult({
    required this.name,
    required this.artist,
    this.coverUrl,
    this.year,
    required this.trackCount,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'artist': artist,
    'coverUrl': coverUrl,
    'year': year,
    'trackCount': trackCount,
  };
}

class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  final _musicRepo = MusicRepository();
  final _playlistRepo = PlaylistRepository();

  SearchResult search(String query, {int limit = 20}) {
    final lowerQuery = query.toLowerCase();
    
    // Search tracks
    final tracks = _musicRepo.search(query, limit: limit);
    
    // Search artists
    final allArtists = _musicRepo.getUniqueArtists();
    final matchingArtists = allArtists
        .where((a) => a.toLowerCase().contains(lowerQuery))
        .take(limit)
        .map((name) {
          final artistTracks = _musicRepo.findByArtist(name);
          return ArtistResult(
            name: name,
            avatarUrl: artistTracks.isNotEmpty ? artistTracks.first.coverUrl : null,
            trackCount: artistTracks.length,
          );
        })
        .toList();
    
    // Search albums
    final allAlbums = _musicRepo.getUniqueAlbums();
    final matchingAlbums = allAlbums
        .where((a) => a.toLowerCase().contains(lowerQuery))
        .take(limit)
        .map((name) {
          final albumTracks = _musicRepo.findByAlbum(name);
          final firstTrack = albumTracks.isNotEmpty ? albumTracks.first : null;
          return AlbumResult(
            name: name,
            artist: firstTrack?.artist ?? 'Unknown',
            coverUrl: firstTrack?.coverUrl,
            year: firstTrack?.year,
            trackCount: albumTracks.length,
          );
        })
        .toList();
    
    // Search playlists (public only)
    // For now, return empty list as we don't have public playlist search
    final playlists = <Playlist>[];
    
    return SearchResult(
      tracks: tracks,
      artists: matchingArtists,
      albums: matchingAlbums,
      playlists: playlists,
    );
  }
}
