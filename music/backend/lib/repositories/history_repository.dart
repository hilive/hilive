import 'package:uuid/uuid.dart';
import '../models/history.dart';

class HistoryRepository {
  static final HistoryRepository _instance = HistoryRepository._internal();
  factory HistoryRepository() => _instance;
  HistoryRepository._internal();

  final _uuid = const Uuid();
  final Map<String, PlayHistory> _history = {};
  final Map<String, List<String>> _userHistory = {}; // userId -> List<historyId>

  PlayHistory? findById(String id) => _history[id];

  List<PlayHistory> findByUserId(String userId, {int page = 1, int pageSize = 20}) {
    final historyIds = _userHistory[userId] ?? [];
    final items = historyIds
        .map((id) => _history[id])
        .whereType<PlayHistory>()
        .toList()
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
    
    final start = (page - 1) * pageSize;
    if (start >= items.length) return [];
    
    return items.skip(start).take(pageSize).toList();
  }

  int countByUserId(String userId) {
    return _userHistory[userId]?.length ?? 0;
  }

  PlayHistory record({
    required String userId,
    required String musicId,
    required int playedDuration,
    bool completed = false,
  }) {
    final id = _uuid.v4();
    final history = PlayHistory(
      id: id,
      userId: userId,
      musicId: musicId,
      playedDuration: playedDuration,
      completed: completed,
      playedAt: DateTime.now(),
    );
    
    _history[id] = history;
    _userHistory.putIfAbsent(userId, () => []).insert(0, id);
    
    // Keep only last 500 records per user
    final userIds = _userHistory[userId]!;
    if (userIds.length > 500) {
      final toRemove = userIds.sublist(500);
      for (final removeId in toRemove) {
        _history.remove(removeId);
      }
      _userHistory[userId] = userIds.sublist(0, 500);
    }
    
    return history;
  }

  void clearByUserId(String userId) {
    final historyIds = _userHistory[userId] ?? [];
    for (final id in historyIds) {
      _history.remove(id);
    }
    _userHistory.remove(userId);
  }

  List<String> getRecentMusicIds(String userId, {int limit = 10}) {
    final historyIds = _userHistory[userId] ?? [];
    final seen = <String>{};
    final result = <String>[];
    
    for (final id in historyIds) {
      final history = _history[id];
      if (history != null && !seen.contains(history.musicId)) {
        seen.add(history.musicId);
        result.add(history.musicId);
        if (result.length >= limit) break;
      }
    }
    
    return result;
  }
}
