import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../providers/player_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/playlist_provider.dart';
import 'desktop_player_bar.dart';

class DesktopScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const DesktopScaffold({super.key, required this.child});

  @override
  ConsumerState<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends ConsumerState<DesktopScaffold> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(playlistProvider.notifier).loadPlaylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final authState = ref.watch(authProvider);
    final playlistState = ref.watch(playlistProvider);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Sidebar
                Container(
                  width: 240,
                  color: AppTheme.surfaceColor,
                  child: Column(
                    children: [
                      // Logo
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              '音乐播放器',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Navigation
                      _buildNavItem(
                        icon: Icons.home,
                        label: '首页',
                        path: '/',
                        currentPath: currentPath,
                      ),
                      _buildNavItem(
                        icon: Icons.explore,
                        label: '发现',
                        path: '/discover',
                        currentPath: currentPath,
                      ),
                      _buildNavItem(
                        icon: Icons.library_music,
                        label: '曲库',
                        path: '/library',
                        currentPath: currentPath,
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Divider(color: AppTheme.cardColor),
                      ),

                      // Playlists section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Text(
                              '我的歌单',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              color: AppTheme.textSecondary,
                              onPressed: () => _showCreatePlaylistDialog(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Playlist items
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: playlistState.items.length,
                          itemBuilder: (context, index) {
                            final playlist = playlistState.items[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.queue_music,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              title: Text(
                                playlist.name,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => context.push('/playlist/${playlist.id}'),
                            );
                          },
                        ),
                      ),

                      // User section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppTheme.cardColor),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppTheme.cardColor,
                              child: Text(
                                authState.user?.username.substring(0, 1).toUpperCase() ?? '?',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                authState.user?.username ?? '用户',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary, size: 20),
                              color: AppTheme.cardColor,
                              onSelected: (value) {
                                if (value == 'logout') {
                                  ref.read(authProvider.notifier).logout();
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'settings',
                                  child: Text('设置', style: TextStyle(color: AppTheme.textPrimary)),
                                ),
                                const PopupMenuItem(
                                  value: 'logout',
                                  child: Text('退出登录', style: TextStyle(color: AppTheme.errorColor)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main content
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),

          // Player bar
          const DesktopPlayerBar(),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String path,
    required String currentPath,
  }) {
    final isSelected = currentPath == path;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => context.go(path),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('创建歌单', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: '歌单名称',
            hintStyle: TextStyle(color: AppTheme.textTertiary),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref.read(playlistProvider.notifier).createPlaylist(controller.text);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}
