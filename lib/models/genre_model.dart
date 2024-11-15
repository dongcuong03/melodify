import 'package:cloud_firestore/cloud_firestore.dart';

class GenreModel {
  String genreName;
  Timestamp createdAt;
  Timestamp? updatedAt; // updatedAt là nullable

  GenreModel({
    required this.genreName,
    required this.createdAt,
    this.updatedAt, // Khởi tạo nullable
  });

  // Chuyển từ Firestore document thành GenreModel
  factory GenreModel.fromMap(Map<String, dynamic> map) {
    return GenreModel(
      genreName: map['genreName'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'], // Chỉ gán nếu có
    );
  }

  // Chuyển GenreModel thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'genreName': genreName,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt, // Ghi trường updatedAt chỉ khi nó khác null
    };
  }
}
