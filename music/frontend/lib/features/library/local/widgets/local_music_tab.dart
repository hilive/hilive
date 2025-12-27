import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/core/theme/app_theme.dart';
import 'package:music_player_app/features/library/local/providers/local_music_provider.dart';
import 'package:music_player_app/features/library/local/widgets/local_music_tile.dart';

/// 本地音乐标签页
class LocalMusicTab extends ConsumerStatefulWidget {
  const LocalMusicTab({super.key});

  @override
  ConsumerState<LocalMusicTab> createState() => _LocalMusicTabState();
}

class _LocalMusicTabState extends ConsumerState<LocalMusicTab> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localMusicState = ref.watch(localMusicProvider);
    final filteredMusics = localMusicState.filteredMusics;

    return Column(
      children: [
        // 操作栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // 统计信息
              Text(
                '${localMusicState.musics.length} 首本地歌曲',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              // 搜索按钮
              IconButton(
                icon: Icon(
                  _showSearch ? Icons.close : Icons.search,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                    if (!_showSearch) {
                      _searchController.clear();
                      ref.read(localMusicProvider.notifier).setSearchQuery('');
                    }
                  });
                },
              ),
              // 排序按钮
              IconButton(
                icon: const Icon(Icons.sort, color: AppTheme.textPrimary),
                onPressed: _showSortOptions,
              ),
              // 添加按钮
              PopupMenuButton<String>(
                icon: const Icon(Icons.add, color: AppTheme.textPrimary),
                color: AppTheme.surfaceColor,
                onSelected: (value) async {
                  if (value == 'files') {
                    await _addFiles();
                  } else if (value == 'folder') {
                    await _scanFolder();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'files',
                    child: Row(
                      children: [
                        Icon(Icons.audio_file, color: AppTheme.textPrimary),
                        SizedBox(width: 12),
                        Text('添加文件', style: TextStyle(color: AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'folder',
                    child: Row(
                      children: [
                        Icon(Icons.folder_open, color: AppTheme.textPrimary),
                        SizedBox(width: 12),
                        Text('扫描文件夹', style: TextStyle(color: AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 搜索框
        if (_showSearch)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: '搜索本地音乐...',
                hintStyle: const TextStyle(color: AppTheme.textTertiary),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textTertiary),
                filled: true,
                fillColor: AppTheme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                ref.read(localMusicProvider.notifier).setSearchQuery(value);
              },
            ),
          ),

        // 音乐列表
        Expanded(
          child: localMusicState.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                )
              : localMusicState.isScanning
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppTheme.primaryColor),
                          const SizedBox(height: 16),
                          const Text(
                            '正在扫描音乐文件...',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : filteredMusics.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () => ref.read(localMusicProvider.notifier).refresh(),
                          color: AppTheme.primaryColor,
                          backgroundColor: AppTheme.surfaceColor,
                          child: ListView.builder(
                            itemCount: filteredMusics.length,
                            itemBuilder: (context, index) {
                              return LocalMusicTile(
                                music: filteredMusics[index],
                                queue: filteredMusics,
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final hasSearchQuery = ref.read(localMusicProvider).searchQuery.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearchQuery ? Icons.search_off : Icons.folder_open,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery ? '没有找到匹配的歌曲' : '还没有添加本地音乐',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          if (!hasSearchQuery) ...[
            const SizedBox(height: 8),
            const Text(
              '点击右上角 + 按钮添加音乐文件',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _addFiles,
                  icon: const Icon(Icons.audio_file),
                  label: const Text('添加文件'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _scanFolder,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('扫描文件夹'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addFiles() async {
    final count = await ref.read(localMusicProvider.notifier).pickAndAddFiles();
    if (count > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已添加 $count 首歌曲')),
      );
    }
  }

  Future<void> _scanFolder() async {
    final count = await ref.read(localMusicProvider.notifier).pickAndScanFolder();
    if (count > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已扫描到 $count 首歌曲')),
      );
    }
  }

  void _showSortOptions() {
    final currentSort = ref.read(localMusicProvider).sortType;
    final ascending = ref.read(localMusicProvider).sortAscending;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '排序方式',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildSortOption(
              icon: Icons.access_time,
              title: '添加时间',
              sortType: SortType.addedAt,
              currentSort: currentSort,
              ascending: ascending,
            ),
            _buildSortOption(
              icon: Icons.sort_by_alpha,
              title: '按标题',
              sortType: SortType.title,
              currentSort: currentSort,
              ascending: ascending,
            ),
            _buildSortOption(
              icon: Icons.person,
              title: '按艺术家',
              sortType: SortType.artist,
              currentSort: currentSort,
              ascending: ascending,
            ),
            _buildSortOption(
              icon: Icons.timer,
              title: '按时长',
              sortType: SortType.duration,
              currentSort: currentSort,
              ascending: ascending,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required IconData icon,
    required String title,
    required SortType sortType,
    required SortType currentSort,
    required bool ascending,
  }) {
    final isSelected = currentSort == sortType;
    
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
        ),
      ),
      trailing: isSelected
          ? Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              color: AppTheme.primaryColor,
              size: 20,
            )
          : null,
      onTap: () {
        ref.read(localMusicProvider.notifier).setSortType(sortType);
        Navigator.pop(context);
      },
    );
  }
}
