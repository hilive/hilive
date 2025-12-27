import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/music_provider.dart';
import '../../shared/widgets/music_tile.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      final musicState = ref.read(musicProvider);
      if (musicState.items.isEmpty) {
        ref.read(musicProvider.notifier).loadMusic();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(musicProvider.notifier).loadMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    final musicState = ref.watch(musicProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '曲库',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // Sort button
                  IconButton(
                    icon: const Icon(Icons.sort, color: AppTheme.textPrimary),
                    onPressed: _showSortOptions,
                  ),
                  // Upload button
                  IconButton(
                    icon: const Icon(Icons.upload, color: AppTheme.textPrimary),
                    onPressed: _showUploadDialog,
                  ),
                ],
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatCard(
                    icon: Icons.music_note,
                    label: '歌曲',
                    value: '${musicState.total}',
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.person,
                    label: '艺术家',
                    value: '-',
                    color: AppTheme.secondaryColor,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.album,
                    label: '专辑',
                    value: '-',
                    color: AppTheme.accentColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Music list
            Expanded(
              child: musicState.isLoading && musicState.items.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryColor),
                    )
                  : musicState.items.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.library_music,
                                size: 64,
                                color: AppTheme.textTertiary,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '曲库是空的',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => ref.read(musicProvider.notifier).refresh(),
                          color: AppTheme.primaryColor,
                          backgroundColor: AppTheme.surfaceColor,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: musicState.items.length + (musicState.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= musicState.items.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                );
                              }
                              return MusicTile(
                                music: musicState.items[index],
                                queue: musicState.items,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
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
            ListTile(
              leading: const Icon(Icons.access_time, color: AppTheme.textPrimary),
              title: const Text('最近添加', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha, color: AppTheme.textPrimary),
              title: const Text('按标题', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppTheme.textPrimary),
              title: const Text('按艺术家', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('上传音乐', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          '音乐上传功能需要在桌面端使用。\n\n支持的格式：MP3, FLAC, WAV, AAC',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}
