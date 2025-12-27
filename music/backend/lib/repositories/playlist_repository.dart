import 'package:uuid/uuid.dart';
import '../models/playlist.dart';

class PlaylistRepository {
  static final PlaylistRepository _instance = PlaylistRepository._internal();
  factory PlaylistRepository() => _instance;
  PlaylistRepository._internal();

  final _uuid = const Uuid();
  final Map<String, Playlist> _playlists = {};
  final Map<String, List<PlaylistTrack>> _playlistTracks = {}; // playlistId -> tracks

  Playlist? findById(String id) => _playlists[id];

  List<Playlist> findByUserId(String userId, {int page = 1, int pageSize = 20}) {
    final items = _playlists.values
        .where((p) => p.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    final start = (page - 1) * pageSize;
    if (start >= items.length) return [];
    
    return items.skip(start).take(pageSize).toList();
  }

  int countByUserId(String userId) {
    return _playlists.values.where((p) => p.userId == userId).length;
  }

  Playlist create({
    required String name,
    String? description,
    String? coverUrl,
    required String userId,
    bool isPublic = false,
  }) {
    final id = _uuid.v4();
    final playlist = Playlist(
      id: id,
      name: name,
      description: description,
      coverUrl: coverUrl,
      userId: userId,
      isPublic: isPublic,
      createdAt: DateTime.now(),
    );
    _playlists[id] = playlist;
    _playlistTracks[id] = [];
    return playlist;
  }

  Playlist? update(String id, {
    String? name,
    String? description,
    String? coverUrl,
    bool? isPublic,
  }) {
    final playlist = _playlists[id];
    if (playlist == null) return null;

    final updated = playlist.copyWith(
      name: name,
      description: description,
      coverUrl: coverUrl,
      isPublic: isPublic,
      updatedAt: DateTime.now(),
    );
    _playlists[id] = updated;
    return updated;
  }

  bool delete(String id) {
    _playlistTracks.remove(id);
    return _playlists.remove(id) != null;
  }

  // Track management
  List<PlaylistTrack> getTracks(String playlistId) {
    return _playlistTracks[playlistId] ?? [];
  }

  List<String> getTrackIds(String playlistId) {
    return getTracks(playlistId).map((t) => t.musicId).toList();
  }

  PlaylistTrack? addTrack(String playlistId, String musicId, {int? position}) {
    final tracks = _playlistTracks[playlistId];
    if (tracks == null) return null;

    // Check if already exists
    if (tracks.any((t) => t.musicId == musicId)) return null;

    final pos = position ?? tracks.length;
    final track = PlaylistTrack(
      id: _uuid.v4(),
      playlistId: playlistId,
      musicId: musicId,
      position: pos,
      addedAt: DateTime.now(),
    );
    
    tracks.add(track);
    tracks.sort((a, b) => a.position.compareTo(b.position));
    _updatePlaylistStats(playlistId);
    
    return track;
  }

  bool removeTrack(String playlistId, String musicId) {
    final tracks = _playlistTracks[playlistId];
    if (tracks == null) return false;

    final removed = tracks.removeWhere((t) => t.musicId == musicId);
    _updatePlaylistStats(playlistId);
    return true;
  }

  void reorderTracks(String playlistId, List<String> musicIds) {
    final tracks = _playlistTracks[playlistId];
    if (tracks == null) return;

    final newTracks = <PlaylistTrack>[];
    for (var i = 0; i < musicIds.length; i++) {
      final existing = tracks.firstWhere(
        (t) => t.musicId == musicIds[i],
        orElse: () => PlaylistTrack(
          id: _uuid.v4(),
          playlistId: playlistId,
          musicId: musicIds[i],
          position: i,
          addedAt: DateTime.now(),
        ),
      );
      newTracks.add(PlaylistTrack(
        id: existing.id,
        playlistId: playlistId,
        musicId: existing.musicId,
        position: i,
        addedAt: existing.addedAt,
      ));
    }
    
    _playlistTracks[playlistId] = newTracks;
    _updatePlaylistStats(playlistId);
  }

  void _updatePlaylistStats(String playlistId) {
    final playlist = _playlists[playlistId];
    if (playlist == null) return;

    final trackCount = _playlistTracks[playlistId]?.length ?? 0;
    _playlists[playlistId] = playlist.copyWith(
      trackCount: trackCount,
      updatedAt: DateTime.now(),
    );
  }

  void updateTotalDuration(String playlistId, int totalDuration) {
    final playlist = _playlists[playlistId];
    if (playlist == null) return;

    _playlists[playlistId] = playlist.copyWith(
      totalDuration: totalDuration,
      updatedAt: DateTime.now(),
    );
  }
}
