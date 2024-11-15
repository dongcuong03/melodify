import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/genre_model.dart';
import '../services/firestore_services.dart';

class GenreProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService(); // Khởi tạo FirestoreService trực tiếp
  List<GenreModel> _genres = [];
  String? _errorMessage;

  List<GenreModel> get genres => _genres;
  String? get errorMessage => _errorMessage;

  // Thêm thể loại mới
  Future<void> addGenre(String genreName) async {
    try {
      _errorMessage = null;
      // Kiểm tra xem thể loại đã tồn tại chưa
      bool exists = await _firestoreService.checkGenreExists(genreName);
      if (exists) {
        _errorMessage = "Tên thể loại đã tồn tại";
        notifyListeners();
        return;
      }

      final genre = GenreModel(genreName: genreName, createdAt: Timestamp.now());

      await _firestoreService.addGenre(genre);
      _genres.add(genre);
      notifyListeners();
    } catch (e) {
      _errorMessage = "Không thể thêm thể loại";
      notifyListeners();
    }
  }

  // Lấy danh sách thể loại từ Firestore
  Future<void> fetchGenres() async {
    try {
      _genres = await _firestoreService.getGenres();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Không thể lấy danh sách thể loại";
      notifyListeners();
    }
  }

  // Cập nhật thể loại
  Future<void> updateGenre(String currentGenreName, String newGenreName) async {
    try {
      _errorMessage = null;
      // Kiểm tra xem thể loại đã tồn tại chưa
      bool exists = await _firestoreService.checkGenreExists(newGenreName);
      if (exists) {
        _errorMessage = "Tên thể loại đã tồn tại";
        notifyListeners();
        return;
      }
      await _firestoreService.updateGenre(currentGenreName, newGenreName);
      _errorMessage = null;
      await fetchGenres(); // Tải lại danh sách sau khi sửa
    } catch (e) {
      _errorMessage = "Lỗi khi cập nhật thể loại: $e";
      notifyListeners();
    }
  }

  // Xóa thể loại
  Future<void> deleteGenre(String genreName) async {
    try {
      await _firestoreService.deleteGenre(genreName);
      _errorMessage = null;
      await fetchGenres(); // Tải lại danh sách sau khi xóa
    } catch (e) {
      _errorMessage = "Lỗi khi xóa thể loại: $e";
      notifyListeners();
    }
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
