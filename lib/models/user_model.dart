class UserModel {
  String fullName;
  String email;
  String role;
  String? avatarUrl;
  List<String>? likedSongs;
  List<String>? playlists;
  UserModel({
    required this.fullName,
    required this.email,
    required this.role,
    this.likedSongs,
    this.playlists,
  });

  // Chuyển đổi từ Map sang UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user', // Mặc định role là 'user'
      likedSongs: List<String>.from(map['likedSongs'] ?? []),
      playlists: List<String>.from(map['playlists'] ?? []),
    );
  }

  // Chuyển UserModel sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'role': role,
      'likedSongs': likedSongs ?? [],
      'playlists': playlists ?? [],
    };
  }
}
