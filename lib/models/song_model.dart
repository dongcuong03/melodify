

import 'package:cloud_firestore/cloud_firestore.dart';

class SongModel {
  String title;
  String artist;
  String genre;
  String audioUrl;
  String lyricUrl;
  String coverUrl;
  Timestamp createdAt;
  Timestamp? updatedAt;

  SongModel({
    required this.title,
    required this.artist,
    required this.genre,
    required this.audioUrl,
    required this.lyricUrl,
    required this.coverUrl,
    required this.createdAt,
    this.updatedAt,
  });

  // Chuyển từ Firestore document thành SongModel
  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      genre: map['genre'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      lyricUrl: map['lyricUrl'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'],
    );
  }

  // Chuyển SongModel thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'genre': genre,
      'audioUrl': audioUrl,
      'lyricUrl': lyricUrl,
      'coverUrl': coverUrl,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
