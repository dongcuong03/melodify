import 'package:flutter/material.dart';

import '../models/song_model.dart';
import '../services/firestore_services.dart';

class SongProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Map<String, dynamic>> _songs = [];
  List<Map<String, dynamic>> get songs => _songs;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  // Thêm bài hát
  Future<void> addSong(SongModel song) async {
    try {
      _errorMessage = null;
      await _firestoreService.addSong(song);
      await fetchSongs(); // Cập nhật lại danh sách sau khi thêm
      notifyListeners();
    } catch (e) {
      print("Không thể thêm bài hát: $e");
      _errorMessage = "Không thể thêm bài hát";
      rethrow;
    }
  }

  // Lấy danh sách bài hát
  Future<void> fetchSongs() async {
    try {
      _songs = await _firestoreService.getSongs();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      print("Không thể lấy danh sách bài hát: $e");
      _errorMessage = "Không thể lấy danh sách bài hát";
      rethrow;
    }
  }

  // Cập nhật bài hát
  Future<void> updateSong(String songId, SongModel updatedSong) async {
    try {
      _errorMessage = null;
      await _firestoreService.updateSong(songId, updatedSong);
      _errorMessage = null;
      await fetchSongs(); // Cập nhật lại danh sách sau khi cập nhật
      notifyListeners();
    } catch (e) {
      print("Không thể cập nhật bài hát: $e");
      _errorMessage = "Không thể cập nhật bài hát";
      rethrow;
    }
  }

  // Xóa bài hát
  Future<void> deleteSong(String songId) async {
    try {
      await _firestoreService.deleteSong(songId);
      _errorMessage = null;
      await fetchSongs(); // Cập nhật lại danh sách sau khi xóa
      notifyListeners();
    } catch (e) {
      print("Không thể xóa bài hát: $e");
      _errorMessage = "Không thể lấy xóa bài hát";
      rethrow;
    }
  }
}
