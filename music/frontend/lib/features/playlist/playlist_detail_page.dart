import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/playlist_provider.dart';
import '../../shared/providers/player_provider.dart';
import '../../shared/widgets/music_tile.dart';

class PlaylistDetailPage extends ConsumerWidget {
  final String playlistId;

  const PlaylistDetailPage({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(playlistDetailProvider(playlistId));

    return Scaffold(
      body: playlistAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (error, _) => Center(
          child: Text('加载失败: $error', style: const TextStyle(color: AppTheme.textSecondary)),
        ),
        data: (playlistWithTracks) {
          if (playlistWithTracks == null) {
            return const Center(
              child: Text('歌单不存在', style: TextStyle(color: AppTheme.textSecondary)),
            );
          }

          final playlist = playlistWithTracks.playlist;
          final tracks = playlistWithTracks.tracks;

          return CustomScrollView(
            slivers: [
              // App bar with cover
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppTheme.backgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.6),
                              AppTheme.backgroundColor,
                            ],
                          ),
                        ),
                      ),
                      // Content
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Cover
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: playlist.coverUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: playlist.coverUrl!,
                                        width: 140,
                                        height: 140,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.primaryGradient,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.queue_music,
                                          color: Colors.white,
                                          size: 64,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              // Info
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      playlist.name,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${playlist.trackCount} 首歌曲 · ${playlist.totalDurationFormatted}',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Play all button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: tracks.isNotEmpty
                              ? () {
                                  ref.read(playerProvider.notifier).playTrack(
                                    tracks.first,
                                    queue: tracks,
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('播放全部'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          if (tracks.isNotEmpty) {
                            final shuffled = List.of(tracks)..shuffle();
                            ref.read(playerProvider.notifier).playTrack(
                              shuffled.first,
                              queue: shuffled,
                            );
                          }
                        },
                        icon: const Icon(Icons.shuffle, color: AppTheme.textPrimary),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.cardColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tracks list
              if (tracks.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      '歌单是空的',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return MusicTile(
                        music: tracks[index],
                        queue: tracks,
                        showIndex: true,
                        index: index,
                      );
                    },
                    childCount: tracks.length,
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }
}
