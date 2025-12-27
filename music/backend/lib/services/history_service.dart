import '../models/history.dart';
import '../models/music.dart';
import '../repositories/history_repository.dart';
import '../repositories/music_repository.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final _historyRepo = HistoryRepository();
  final _musicRepo = MusicRepository();

  ({List<PlayHistoryWithMusic> items, int total}) getByUserId(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) {
    final history = _historyRepo.findByUserId(userId, page: page, pageSize: pageSize);
    final total = _historyRepo.countByUserId(userId);

    final items = history.map((h) {
      final music = _musicRepo.findById(h.musicId);
      if (music == null) return null;
      return PlayHistoryWithMusic(history: h, music: music);
    }).whereType<PlayHistoryWithMusic>().toList();

    return (items: items, total: total);
  }

  PlayHistory record({
    required String userId,
    required String musicId,
    required int playedDuration,
    bool completed = false,
  }) {
    final music = _musicRepo.findById(musicId);
    if (music != null && completed) {
      _musicRepo.incrementPlayCount(musicId);
    }

    return _historyRepo.record(
      userId: userId,
      musicId: musicId,
      playedDuration: playedDuration,
      completed: completed,
    );
  }

  void clear(String userId) {
    _historyRepo.clearByUserId(userId);
  }

  List<Music> getRecentlyPlayed(String userId, {int limit = 10}) {
    final musicIds = _historyRepo.getRecentMusicIds(userId, limit: limit);
    return _musicRepo.findByIds(musicIds);
  }
}
