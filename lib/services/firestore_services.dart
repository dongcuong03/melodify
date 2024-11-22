import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:melodify/models/user_model.dart';

import '../models/genre_model.dart';
import '../models/song_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//USER
  Future<void> addUserToFirestore(UserModel user, String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set(user.toMap());
    } catch (e) {
      print('Lỗi khi thêm người dùng vào Firestore: $e');
    }
  }

  // Lấy thông tin người dùng từ Firestore
  Future<UserModel?> getUserFromFirestore(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng từ Firestore: $e');
    }
    return null;
  }

  // Lấy role của người dùng qua email
  Future<String?> getUserRole(String email) async {
    try {
      // Truy vấn để tìm tất cả các tài liệu có trường 'email' khớp
      QuerySnapshot snapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();

      // Kiểm tra nếu có tài liệu nào khớp
      if (snapshot.docs.isNotEmpty) {
        // Lấy role từ tài liệu đầu tiên
        String role = snapshot.docs.first.get('role');
        print('Quyền của người dùng $email là: $role');
        return role;
      } else {
        print('Người dùng không tồn tại với email: $email');
        return null;
      }
    } catch (e) {
      print('Lỗi khi lấy quyền người dùng: $e');
      return null;
    }
  }
  // Lấy thông tin người dùng từ Firestore theo email
  Future<UserModel?> getUserByEmail(String email) async {
    QuerySnapshot snapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
    if (snapshot.docs.isNotEmpty) {
      return UserModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Hàm gửi mã OTP vào Firestore
  Future<void> saveOtp(String email, String otp, createdAt) async {
    // Lưu mã OTP vào Firestore
    await _firestore.collection('otps').add({
      'email': email,
      'otp': otp,
      'createdAt': Timestamp.fromDate(createdAt),
    });
  }

  // Hàm  lấy mã xác nhận mã OTP
  Future<String?> getOtp(String email) async {
    try {
      // Truy vấn tài liệu với email tương ứng
      QuerySnapshot snapshot = await _firestore.collection('otps').where('email', isEqualTo: email).get();

      // Lấy tài liệu đầu tiên
      DocumentSnapshot doc = snapshot.docs.first;
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      DateTime createdAt = (data?['createdAt'] as Timestamp).toDate();
      DateTime expirationTime = createdAt.add(Duration(minutes: 5)); // Thêm 5 phút

      // Kiểm tra thời gian hết hạn
      if (DateTime.now().isBefore(expirationTime)) {
        return data?['otp']; // Trả về OTP nếu chưa hết hạn
      } else {
        // Xóa tất cả tài liệu OTP đã hết hạn dựa trên email
        await _firestore.collection('otps').where('email', isEqualTo: email).get().then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete(); // Xóa từng tài liệu
          }
        });
        return null; // Mã OTP không hợp lệ
      }
    } catch (e) {
      print('Lỗi khi lấy mã OTP: $e');
    }
    return null; // Trả về null nếu không tìm thấy hoặc có lỗi
  }

  Future<void> deleteOtp(String email) async {
    await _firestore.collection('otps').where('email', isEqualTo: email).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete(); // Xóa từng tài liệu
      }
    });
  }


//GENRE
  Future<bool> checkGenreExists(String genreName) async {
    try {
      final querySnapshot = await _firestore
          .collection('genres')
          .where('genreName', isEqualTo: genreName)
          .limit(1)
          .get();

      // Kiểm tra xem có tài liệu nào không
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // In ra lỗi nếu có vấn đề trong quá trình truy vấn
      print("Lỗi khi kiểm tra thể loại: $e");
      return false; // Trả về false nếu có lỗi trong quá trình truy vấn
    }
  }


  Future<void> addGenre(GenreModel genre) async {
    try {
      await _firestore.collection('genres').add({
        ...genre.toMap(),
        'createdAt': Timestamp.now(), // Thêm thời điểm tạo mới
        'updatedAt': null,
      });
    } catch (e) {
      throw Exception("Không thể thêm thể loại: $e");
    }
  }

  Future<List<GenreModel>> getGenres() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('genres')
          .orderBy('createdAt', descending: true) // Sắp xếp theo createdAt mới nhất
          .get();

      return snapshot.docs.map((doc) {
        return GenreModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception("Không thể lấy danh sách thể loại: $e");
    }
  }

  Future<void> updateGenre(String currentGenreName, String newGenreName) async {
    try {
      // Truy vấn để lấy tài liệu có tên thể loại hiện tại
      QuerySnapshot snapshot = await _firestore
          .collection('genres')
          .where('genreName', isEqualTo: currentGenreName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Cập nhật thể loại
        await snapshot.docs.first.reference.update({
          'genreName': newGenreName,
          'updatedAt': Timestamp.now(), // Thời gian cập nhật mới
        });
      } else {
        throw Exception("Không tìm thấy thể loại cần sửa!");
      }
    } catch (e) {
      print("Lỗi khi cập nhật thể loại: $e");
      throw Exception("Không thể cập nhật thể loại: $e");
    }
  }

  // Xóa thể loại từ Firestore
  Future<void> deleteGenre(String genreName) async {
    try {
      // Tìm tài liệu thể loại bằng tên
      QuerySnapshot snapshot = await _firestore
          .collection('genres')
          .where('genreName', isEqualTo: genreName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Xóa tài liệu đầu tiên tìm được
        await snapshot.docs.first.reference.delete();
      } else {
        throw Exception("Không tìm thấy thể loại để xóa!");
      }
    } catch (e) {
      print("Lỗi khi xóa thể loại: $e");
      throw Exception("Không thể xóa thể loại: $e");
    }
  }

//SONGS
  //Hàm thêm bài hát
  Future<void> addSong(SongModel song) async{
    try {
      await _firestore.collection('songs').add({
        ...song.toMap(),
        'createdAt': Timestamp.now(), // Thêm thời điểm tạo mới
        'updatedAt': null,
      });
    } catch (e) {
      throw Exception("Không thể thêm thể loại: $e");
    }
  }

  //Select bài hát
  Future<List<Map<String, dynamic>>> getSongs() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('songs')
          .orderBy('createdAt', descending: true)
          .get();

      // Duyệt qua từng tài liệu và lấy dữ liệu + `id`
      return snapshot.docs.map((doc) {
        final songData = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,  // `id` của tài liệu Firestore
          'song': SongModel.fromMap(songData),
        };
      }).toList();
    } catch (e) {
      throw Exception("Không thể lấy danh sách bài hát: $e");
    }
  }

  Future<void> updateSong(
      String songId, {
        required String title,
        required String artist,
        required String genre,
        required String audioUrl,
        required String lyricUrl,
        required String coverUrl,
      }) async {
    try {
      // Tạo một Map chỉ chứa các trường cần cập nhật
      Map<String, dynamic> updatedData = {};

      updatedData['title'] = title;
      updatedData['artist'] = artist;
      updatedData['genre'] = genre;
      updatedData['audioUrl'] = audioUrl;
      updatedData['lyricUrl'] = lyricUrl;
      updatedData['coverUrl'] = coverUrl;

      // Cập nhật thời gian chỉnh sửa
      updatedData['updatedAt'] = Timestamp.now();

      // Cập nhật dữ liệu vào Firestore
      await _firestore.collection('songs').doc(songId).update(updatedData);
      print('Cập nhật bài hát thành công');
    } catch (e) {
      print('Lỗi khi cập nhật bài hát: $e');
      rethrow;
    }
  }


  // Hàm xóa bài hát
  Future<void> deleteSong(String songId) async {
    try {
      await _firestore.collection('songs').doc(songId).delete();
      print('Xóa bài hát thành công');
    } catch (e) {
      print('Lỗi khi xóa bài hát: $e');
      rethrow;
    }
  }

  // Lấy danh sách các `coverUrl` từ Firestore
  Future<List<String>> getCoverUrls() async {
    try {
      final snapshot = await _firestore.collection('songs').get();
      final rawUrls = snapshot.docs.map((doc) => doc['coverUrl'] as String).toList();
      return rawUrls.map(_convertToDirectLink).toList();
    } catch (e) {
      throw Exception('Error fetching cover URLs: $e');
    }
  }

  // Chuyển đổi liên kết Google Drive thành liên kết trực tiếp
  String _convertToDirectLink(String url) {
    final fileId = RegExp(r'/file/d/(.*?)/view').firstMatch(url)?.group(1);
    if (fileId != null) {
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }
    return url; // Trả về link gốc nếu không phù hợp
  }
}
