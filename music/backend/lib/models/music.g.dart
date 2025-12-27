// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Music _$MusicFromJson(Map<String, dynamic> json) => Music(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      coverUrl: json['coverUrl'] as String?,
      audioUrl: json['audioUrl'] as String,
      duration: (json['duration'] as num).toInt(),
      trackNumber: (json['trackNumber'] as num?)?.toInt(),
      genre: json['genre'] as String?,
      year: (json['year'] as num?)?.toInt(),
      bitrate: (json['bitrate'] as num?)?.toInt(),
      format: json['format'] as String?,
      fileSize: (json['fileSize'] as num).toInt(),
      uploaderId: json['uploaderId'] as String,
      isPublic: json['isPublic'] as bool? ?? true,
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MusicToJson(Music instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'album': instance.album,
      'coverUrl': instance.coverUrl,
      'audioUrl': instance.audioUrl,
      'duration': instance.duration,
      'trackNumber': instance.trackNumber,
      'genre': instance.genre,
      'year': instance.year,
      'bitrate': instance.bitrate,
      'format': instance.format,
      'fileSize': instance.fileSize,
      'uploaderId': instance.uploaderId,
      'isPublic': instance.isPublic,
      'playCount': instance.playCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
