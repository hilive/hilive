import '../models/playlist.dart';
import '../models/music.dart';
import '../repositories/playlist_repository.dart';
import '../repositories/music_repository.dart';

class PlaylistService {
  static final PlaylistService _instance = PlaylistService._internal();
  factory PlaylistService() => _instance;
  PlaylistService._internal();

  final _playlistRepo = PlaylistRepository();
  final _musicRepo = MusicRepository();

  Playlist? getById(String id) => _playlistRepo.findById(id);

  ({List<Playlist> items, int total}) getByUserId(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) {
    final items = _playlistRepo.findByUserId(userId, page: page, pageSize: pageSize);
    final total = _playlistRepo.countByUserId(userId);
    return (items: items, total: total);
  }

  Playlist create({
    required String name,
    String? description,
    String? coverUrl,
    required String userId,
    bool isPublic = false,
  }) {
    return _playlistRepo.create(
      name: name,
      description: description,
      coverUrl: coverUrl,
      userId: userId,
      isPublic: isPublic,
    );
  }

  Playlist? update(String id, String userId, {
    String? name,
    String? description,
    String? coverUrl,
    bool? isPublic,
  }) {
    final playlist = _playlistRepo.findById(id);
    if (playlist == null || playlist.userId != userId) return null;

    return _playlistRepo.update(
      id,
      name: name,
      description: description,
      coverUrl: coverUrl,
      isPublic: isPublic,
    );
  }

  bool delete(String id, String userId) {
    final playlist = _playlistRepo.findById(id);
    if (playlist == null || playlist.userId != userId) return false;
    return _playlistRepo.delete(id);
  }

  PlaylistWithTracks? getWithTracks(String id, String? userId) {
    final playlist = _playlistRepo.findById(id);
    if (playlist == null) return null;
    
    // Check access
    if (!playlist.isPublic && playlist.userId != userId) return null;

    final trackIds = _playlistRepo.getTrackIds(id);
    final tracks = _musicRepo.findByIds(trackIds);
    
    // Sort tracks by position
    final orderedTracks = <Music>[];
    for (final trackId in trackIds) {
      final music = tracks.firstWhere(
        (m) => m.id == trackId,
        orElse: () => tracks.first,
      );
      if (tracks.any((m) => m.id == trackId)) {
        orderedTracks.add(music);
      }
    }

    return PlaylistWithTracks(playlist: playlist, tracks: orderedTracks);
  }

  bool addTrack(String playlistId, String musicId, String userId, {int? position}) {
    final playlist = _playlistRepo.findById(playlistId);
    if (playlist == null || playlist.userId != userId) return false;

    final music = _musicRepo.findById(musicId);
    if (music == null) return false;

    final track = _playlistRepo.addTrack(playlistId, musicId, position: position);
    if (track != null) {
      _updateTotalDuration(playlistId);
    }
    return track != null;
  }

  bool removeTrack(String playlistId, String musicId, String userId) {
    final playlist = _playlistRepo.findById(playlistId);
    if (playlist == null || playlist.userId != userId) return false;

    final result = _playlistRepo.removeTrack(playlistId, musicId);
    if (result) {
      _updateTotalDuration(playlistId);
    }
    return result;
  }

  void reorderTracks(String playlistId, String userId, List<String> musicIds) {
    final playlist = _playlistRepo.findById(playlistId);
    if (playlist == null || playlist.userId != userId) return;

    _playlistRepo.reorderTracks(playlistId, musicIds);
    _updateTotalDuration(playlistId);
  }

  void _updateTotalDuration(String playlistId) {
    final trackIds = _playlistRepo.getTrackIds(playlistId);
    final tracks = _musicRepo.findByIds(trackIds);
    final totalDuration = tracks.fold<int>(0, (sum, m) => sum + m.duration);
    _playlistRepo.updateTotalDuration(playlistId, totalDuration);
  }
}
