import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;

import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleDriveService {
  final List<String> _scopes = [drive.DriveApi.driveFileScope];

  // Hàm khởi tạo và xác thực Google Drive API
  Future<drive.DriveApi> _getDriveApi() async {
    // Đọc tệp JSON từ assets
    final accountCredentials = await rootBundle.loadString('assets/melodify-441216-bf0a83f5fd2d.json');
    final credentials = ServiceAccountCredentials.fromJson(accountCredentials);

    // Xác thực và tạo một client mới
    final client = await clientViaServiceAccount(credentials, _scopes);
    return drive.DriveApi(client);
  }

  // Hàm tải tệp lên Google Drive
  Future<String> uploadFile(File file, String folderId) async {
    final driveApi = await _getDriveApi();

    final media = drive.Media(file.openRead(), file.lengthSync());
    final driveFile = drive.File()
      ..name = path.basename(file.path)
      ..parents = [folderId]; // Thư mục mà bạn muốn tải tệp vào

    final response = await driveApi.files.create(driveFile, uploadMedia: media);
    return response.id ?? 'Không thể tải tệp lên';
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      // Trích xuất fileId từ URL
      final fileId = extractFileId(fileUrl);

      if (fileId != null) {
        final driveApi = await _getDriveApi();
        await driveApi.files.delete(fileId);
        print('Tệp đã được xóa thành công.');
      } else {
        print('Không thể trích xuất fileId từ URL.');
      }
    } catch (e) {
      print('Không thể xóa tệp: $e');
    }
  }

  // Hàm trích xuất fileId từ URL Google Drive
  String? extractFileId(String fileUrl) {
    final regex = RegExp(r'\/d\/([a-zA-Z0-9_-]+)\/');
    final match = regex.firstMatch(fileUrl);

    if (match != null && match.group(1) != null) {
      return match.group(1);  // Trả về fileId
    } else {
      return null;  // Không tìm thấy fileId trong URL
    }
  }

  Future<String> getFileInfo(String fileId) async {
    try {
      // Khởi tạo Google Drive API
      final driveApi = await _getDriveApi();

      // Gọi Google Drive API để lấy thông tin file và ép kiểu
      final drive.File file = (await driveApi.files.get(
        fileId,
        $fields: 'name, mimeType, size', // Các trường cần lấy
      )) as drive.File;

      // Xử lý thông tin file
      print('File Name: ${file.name}');
      print('File Type: ${file.mimeType}');
      print('File Size: ${file.size} bytes');

      return file.name ?? 'Không tìm thấy tên tệp';
    } catch (e) {
      print('Không thể lấy thông tin tệp: $e');
      return 'Lỗi khi lấy thông tin tệp';
    }
  }




}
