import 'dart:io';
import 'package:flutter/material.dart';
import '../services/google_driver_service.dart';

class GoogleDriveProvider extends ChangeNotifier {
  final GoogleDriveService _googleDriveService = GoogleDriveService();

  String _statusMessage = '';
  String? _fileId;
  String? _fileName;

  String get statusMessage => _statusMessage;
  String? get fileId => _fileId;
  String? get fileName => _fileName;

  // Hàm tải tệp lên Google Drive và trả về link đến file
  Future<String> uploadFile(File file, String folderId) async {
    _statusMessage = 'Đang tải lên...';
    notifyListeners();

    try {
      // Gọi service để upload file và nhận ID của file
      final fileId = await _googleDriveService.uploadFile(file, folderId);

      // Tạo link URL đầy đủ trỏ đến file trên Google Drive
      final fileUrl = "https://drive.google.com/file/d/$fileId/view?usp=sharing";

      _statusMessage = 'Tải lên thành công.';
      notifyListeners();
      return fileUrl; // Trả về link đầy đủ
    } catch (e) {
      _statusMessage = 'Lỗi: $e';
      notifyListeners();
      rethrow; // Để xử lý lỗi ở phía gọi hàm
    }
  }

  // Hàm xóa tệp trên Google Drive
  Future<void> deleteFile(String fileUrl) async {
    try {
      await _googleDriveService.deleteFile(fileUrl);
      _statusMessage = 'Tệp đã được xóa.';
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Lỗi: Không thể xóa tệp.';
      print('Error in Provider: $e');
      notifyListeners();
    }
  }

  // Hàm trích xuất fileId từ URL
  String? extractFileId(String fileUrl) {
    _fileId = _googleDriveService.extractFileId(fileUrl);
    notifyListeners();
    return _fileId; // Trả về fileId
  }

  // Hàm lấy tên file từ fileId
  Future<String?> fetchFileName(String fileId) async {
    try {
      _fileName = await _googleDriveService.getFileInfo(fileId);
      notifyListeners();
      return _fileName; // Trả về tên file
    } catch (e) {
      rethrow;
    }
  }
}
