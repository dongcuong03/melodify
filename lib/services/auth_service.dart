import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:melodify/models/user_model.dart';
import 'firestore_services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  DateTime? _otpCreatedAt; // Thời gian mã OTP được tạo ra

  // Kiểm tra xem email đã tồn tại hay chưa
  Future<bool> isEmailExists(String email) async {
    try {
      final QuerySnapshot result = await _db
          .collection('users') //
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return result.docs.isNotEmpty; // Nếu có ít nhất 1 tài liệu, email tồn tại
    } catch (e) {
      print('Lỗi khi kiểm tra email: $e');
      return false; // Nếu có lỗi, mặc định cho là email không tồn tại
    }
  }

  // Đăng ký với email và mật khẩu
  Future<UserModel?> registerUserWithEmail(
      String email, String password, String fullName) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        UserModel newUser = UserModel(
          email: email,
          fullName: fullName,
          role: 'user', // mặc định role là user
          likedSongs: [],
          playlists: [],
        );
        await FirestoreService().addUserToFirestore(newUser, user.uid);
        return newUser;
      }
    } catch (e) {
      print('Lỗi khi đăng ký với email: $e');
    }
    return null;
  }

  //Đăng nhập với email và mật khẩu
  Future<UserModel?> loginUseWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Lấy thông tin người dùng từ Firestore
        UserModel? userModel = await _firestoreService.getUserByEmail(email);
        return userModel; // Trả về thông tin người dùng
      }
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      return null; // Trả về null nếu không thành công
    }

    return null; // Trả về null nếu không thành công
  }

  // kiểm tra quyền
  Future<String?> checkUserRole(String email) async {
    return await _firestoreService
        .getUserRole(email); // Trả về vai trò người dùng
  }

// Đăng xuất
  Future<void> signOutUser() async {
    await GoogleSignIn().signOut();

    await _auth.signOut();
  }


  // Đăng nhập bằng Google

  Future<UserModel?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Người dùng hủy đăng nhập

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final String googleEmail = googleUser.email; // Lưu email từ googleUser
      UserCredential userCredential = await _auth.signInWithCredential(googleCredential);
      final User? user = userCredential.user;

      if (user != null) {
        final existingUser = await _db
            .collection('users')
            .where('email', isEqualTo: googleEmail)
            .limit(1)
            .get();

        if (existingUser.docs.isNotEmpty) {
          return UserModel(
            email: existingUser.docs.first.data()['email'],
            fullName: existingUser.docs.first.data()['fullName'],
            role: existingUser.docs.first.data()['role'],
            likedSongs: List<String>.from(existingUser.docs.first.data()['likedSongs'] ?? []),
            playlists: List<String>.from(existingUser.docs.first.data()['playlists'] ?? []),
          );
        } else {
          await _db.collection('users').doc(user.uid).set({
            'email': googleEmail, // Lưu email từ googleEmail
            'fullName': user.displayName ?? '',
            'role': 'user',
            'likedSongs': [],
            'playlists': [],
          });
          return UserModel(
            email: googleEmail, // Sử dụng googleEmail
            fullName: user.displayName ?? '',
            role: 'user',
            likedSongs: [],
            playlists: [],
          );
        }
      }
    } catch (e) {
      print('Lỗi đăng nhập Google: $e');
      rethrow; // Trả về lỗi để xử lý trong provider
    }
    return null; // Trả về null nếu không thành công
  }

  //Tạo mã OTP ngẫu nhiên
  String generateOtp() {
    final Random random = Random();
    return (10000 + random.nextInt(90000)).toString(); // Tạo mã 5 chữ số
  }
  // Gửi email chứa OTP
  Future<void> sendOtp(String email) async {
    String _otp = generateOtp(); // Tạo mã OTP
    DateTime createdAt = DateTime.now(); // Ghi lại thời gian tạo mã OTP
    // Lưu mã OTP vào Firestore
    await _firestoreService.saveOtp(email, _otp, createdAt);

    // Tạo email chứa mã OTP
    final message = Message()
      ..from = Address('dongvancuong06@gmail.com', 'Melodify')
      ..recipients.add(email)
      ..subject = 'Your OTP Code'
      ..text = 'Your OTP code is: $_otp'; // Nội dung email chứa mã OTP

    await sendEmail(message); // Gọi hàm gửi email
  }

  // Hàm gửi email
  Future<void> sendEmail(Message message) async {
    try {
      final smtpServer = gmail('dongvancuong06@gmail.com', 'xqdl uklb oyws tkbo'); // Sử dụng tài khoản Gmail
      final sendReport = await send(message, smtpServer);
      print('Email gửi thành công: ' + sendReport.toString());
    } catch (e) {
      print('Lỗi khi gửi email: $e');
    }
  }

  // Hàm xác thực OTP
  Future<bool> verifyOtp(String email, String inputOtp) async {
    String? storedOtp = await _firestoreService.getOtp(email); // Lấy OTP từ Firestore
    if (storedOtp != null && storedOtp == inputOtp) {
      // Xóa OTP sau khi xác thực thành công nếu cần
      await _firestoreService.deleteOtp(email);
      return true; // Xác thực thành công
    }
    return false; // Xác thực thất bại
  }

  // Hàm gửi email đặt lại mật khâ khi bấm quên mật khẩu
  Future<void> sendPasswordResetEmail(String email) async{
    try{
      await _auth.sendPasswordResetEmail(email: email);

    }catch(error){
      throw error;
    }
  }

}
