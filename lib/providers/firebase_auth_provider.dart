import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:melodify/models/user_model.dart';
import 'package:melodify/services/firestore_services.dart';
import '../services/auth_service.dart';

class FirebaseAuthProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  String? _errorMessage; // Biến để lưu thông báo lỗi
  String? get errorMessage => _errorMessage;
  bool _isLoading = false;
  bool _requiresEmail = false;
  bool get isLoading => _isLoading;
  bool get requiresEmail => _requiresEmail;
  final AuthService _authService = AuthService();
  // Đăng ký
  Future<void> registerWithEmail(
      String email, String password, String fullname) async {
    // Kiểm tra email đã tồn tại
    if (await AuthService().isEmailExists(email)) {
      _errorMessage = 'Email đã tồn tại!';
      notifyListeners();
      return; // Dừng lại nếu email đã tồn tại
    }

    _user = await AuthService().registerUserWithEmail(email, password, fullname);
    _errorMessage = null; // Reset thông báo lỗi khi đăng ký thành công
    notifyListeners();
  }

  // Đăng nhập với email, password
  Future<void> loginWithEmail(String email, String password) async {
    _errorMessage = null; // Reset thông báo lỗi trước khi kiểm tra

    // Kiểm tra xem email có tồn tại không
    if (!(await AuthService().isEmailExists(email))) {
      _errorMessage = 'Email không tồn tại'; // Email không tồn tại
      notifyListeners();
      return; // Dừng lại nếu email không tồn tại
    }

    try {
      // Thử đăng nhập và nhận người dùng
      _user = await AuthService().loginUseWithEmail(email, password);

      // Kiểm tra thông tin người dùng
      if (_user == null) {
        _errorMessage = 'Mật khẩu không chính xác'; // Mật khẩu không đúng
      }
    } catch (e) {
      _errorMessage = 'Đăng nhập không thành công: $e'; // Xử lý trường hợp lỗi khác
    }

    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null; // Xóa thông báo lỗi cũ
    notifyListeners();
  }

  // Thêm phương thức kiểm tra vai trò người dùng
  Future<String?> checkUserRole(String email) async {
    return await AuthService().checkUserRole(email);
  }

  // Đăng xuất
  Future<void> signOut() async {
    await AuthService().signOutUser();
    _user = null;
    notifyListeners();
  }

  // Đăng nhập bằng Google
  Future<String?> signInWithGoogle() async {
    _errorMessage = null; // Reset lỗi trước khi đăng nhập
    try {
      final UserModel? user = await AuthService().signInWithGoogle();
      if (user != null) {
        _user = user; // Lưu thông tin người dùng vào provider
        _errorMessage = null; // Đăng nhập thành công
        notifyListeners();
        return null; // Không có lỗi
      }else {
        // Người dùng hủy đăng nhập, không thực hiện gì thêm
        return null;
      }
    } catch (e) {
      _errorMessage = 'Đăng nhập Google không thành công: $e'; // Trường hợp không có user
    }
    notifyListeners();
    return _errorMessage; // Trả về thông báo lỗi nếu có
  }

  // Gửi mã OTP
  Future<void> sendOtp(String email) async {
    await AuthService().sendOtp(email);
  }

  // Xác nhận mã OTP
  Future<bool> verifyOtp(String email, String inputOtp) async {
   return await AuthService().verifyOtp(email, inputOtp);
  }

  //Xóa OTP
  Future<void> deleteOtp(String email) async {
    await FirestoreService().deleteOtp(email);
  }

  // Gửi email đặt lại mật khẩu khi bấm quên mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    await AuthService().sendPasswordResetEmail(email);
    notifyListeners();
  }


}