import 'dart:io';
import 'package:flutter/material.dart';

import '../services/google_driver_service.dart';

class GoogleDriveProvider extends ChangeNotifier {
  final GoogleDriveService _googleDriveService = GoogleDriveService();
  String _statusMessage = '';
  String get statusMessage => _statusMessage;

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
      return fileUrl;  // Trả về link đầy đủ
    } catch (e) {
      _statusMessage = 'Lỗi: $e';
      notifyListeners();
      rethrow; // Để xử lý lỗi ở phía gọi hàm
    }
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      await _googleDriveService.deleteFile(fileUrl);
      notifyListeners();
    } catch (e) {
      print('Error in Provider: $e');

    }
  }
}

