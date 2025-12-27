import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_player_app/shared/models/local_music.dart';
import 'package:music_player_app/features/library/local/services/file_scanner_service.dart';

/// 本地音乐状态
class LocalMusicState {
  final List<LocalMusic> musics;
  final bool isLoading;
  final bool isScanning;
  final String? error;
  final String searchQuery;
  final SortType sortType;
  final bool sortAscending;

  const LocalMusicState({
    this.musics = const [],
    this.isLoading = false,
    this.isScanning = false,
    this.error,
    this.searchQuery = '',
    this.sortType = SortType.addedAt,
    this.sortAscending = false,
  });

  /// 获取过滤和排序后的音乐列表
  List<LocalMusic> get filteredMusics {
    var result = musics.toList();

    // 搜索过滤
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((m) {
        return m.title.toLowerCase().contains(query) ||
            m.artist.toLowerCase().contains(query) ||
            (m.album?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // 排序
    result.sort((a, b) {
      int comparison;
      switch (sortType) {
        case SortType.title:
          comparison = a.title.compareTo(b.title);
          break;
        case SortType.artist:
          comparison = a.artist.compareTo(b.artist);
          break;
        case SortType.addedAt:
          comparison = a.addedAt.compareTo(b.addedAt);
          break;
        case SortType.duration:
          comparison = a.duration.compareTo(b.duration);
          break;
      }
      return sortAscending ? comparison : -comparison;
    });

    return result;
  }

  LocalMusicState copyWith({
    List<LocalMusic>? musics,
    bool? isLoading,
    bool? isScanning,
    String? error,
    String? searchQuery,
    SortType? sortType,
    bool? sortAscending,
  }) {
    return LocalMusicState(
      musics: musics ?? this.musics,
      isLoading: isLoading ?? this.isLoading,
      isScanning: isScanning ?? this.isScanning,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      sortType: sortType ?? this.sortType,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

/// 排序类型
enum SortType {
  title,
  artist,
  addedAt,
  duration,
}

/// 本地音乐状态管理
class LocalMusicNotifier extends StateNotifier<LocalMusicState> {
  final FileScannerService _scannerService;
  static const _storageKey = 'local_music_list';

  LocalMusicNotifier(this._scannerService) : super(const LocalMusicState()) {
    _loadFromStorage();
  }

  /// 从本地存储加载音乐列表
  Future<void> _loadFromStorage() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        final musics =
            jsonList.map((e) => LocalMusic.fromJson(e)).toList();
        state = state.copyWith(musics: musics, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '加载本地音乐失败: $e');
    }
  }

  /// 保存音乐列表到本地存储
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.musics.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      // 忽略存储错误
    }
  }

  /// 选择并添加音乐文件
  Future<int> pickAndAddFiles() async {
    state = state.copyWith(isScanning: true);
    try {
      final newMusics = await _scannerService.pickFiles();
      if (newMusics.isNotEmpty) {
        await _addMusics(newMusics);
      }
      state = state.copyWith(isScanning: false);
      return newMusics.length;
    } catch (e) {
      state = state.copyWith(isScanning: false, error: '添加文件失败: $e');
      return 0;
    }
  }

  /// 选择并扫描文件夹
  Future<int> pickAndScanFolder() async {
    state = state.copyWith(isScanning: true);
    try {
      final newMusics = await _scannerService.pickFolder();
      if (newMusics.isNotEmpty) {
        await _addMusics(newMusics);
      }
      state = state.copyWith(isScanning: false);
      return newMusics.length;
    } catch (e) {
      state = state.copyWith(isScanning: false, error: '扫描文件夹失败: $e');
      return 0;
    }
  }

  /// 添加音乐（去重）
  Future<void> _addMusics(List<LocalMusic> newMusics) async {
    final existingPaths = state.musics.map((m) => m.filePath).toSet();
    final uniqueMusics =
        newMusics.where((m) => !existingPaths.contains(m.filePath)).toList();

    if (uniqueMusics.isNotEmpty) {
      final updatedMusics = [...state.musics, ...uniqueMusics];
      state = state.copyWith(musics: updatedMusics);
      await _saveToStorage();
    }
  }

  /// 删除音乐
  Future<void> removeMusic(String id) async {
    final updatedMusics = state.musics.where((m) => m.id != id).toList();
    state = state.copyWith(musics: updatedMusics);
    await _saveToStorage();
  }

  /// 批量删除音乐
  Future<void> removeMusics(List<String> ids) async {
    final idsSet = ids.toSet();
    final updatedMusics =
        state.musics.where((m) => !idsSet.contains(m.id)).toList();
    state = state.copyWith(musics: updatedMusics);
    await _saveToStorage();
  }

  /// 清空所有本地音乐
  Future<void> clearAll() async {
    state = state.copyWith(musics: []);
    await _saveToStorage();
  }

  /// 设置搜索关键词
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// 设置排序方式
  void setSortType(SortType type) {
    if (state.sortType == type) {
      // 如果点击相同的排序类型，切换升降序
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      state = state.copyWith(sortType: type, sortAscending: false);
    }
  }

  /// 更新播放次数
  Future<void> incrementPlayCount(String id) async {
    final index = state.musics.indexWhere((m) => m.id == id);
    if (index != -1) {
      final music = state.musics[index];
      final updatedMusic = music.copyWith(
        playCount: music.playCount + 1,
        lastPlayedAt: DateTime.now(),
      );
      final updatedMusics = [...state.musics];
      updatedMusics[index] = updatedMusic;
      state = state.copyWith(musics: updatedMusics);
      await _saveToStorage();
    }
  }

  /// 刷新音乐列表（检查文件是否仍然存在）
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      final validMusics = <LocalMusic>[];
      for (final music in state.musics) {
        final exists = await _checkFileExists(music.filePath);
        if (exists) {
          validMusics.add(music);
        }
      }
      state = state.copyWith(musics: validMusics, isLoading: false);
      await _saveToStorage();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '刷新失败: $e');
    }
  }

  Future<bool> _checkFileExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}

/// Provider 定义
final fileScannerServiceProvider = Provider<FileScannerService>((ref) {
  return FileScannerService();
});

final localMusicProvider =
    StateNotifierProvider<LocalMusicNotifier, LocalMusicState>((ref) {
  final scannerService = ref.watch(fileScannerServiceProvider);
  return LocalMusicNotifier(scannerService);
});
