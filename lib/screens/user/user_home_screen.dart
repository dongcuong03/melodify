import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/firebase_auth_provider.dart';
import '../auth/login_screen.dart';

class UserHomeScreen extends StatefulWidget {
  final UserModel? user;
  const UserHomeScreen({Key? key, this.user}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  Future<void> _dx() async {
    await Provider.of<FirebaseAuthProvider>(context, listen: false).signOut();
    // Sử dụng pushReplacement để không cho phép quay lại màn hình này sau khi đăng xuất
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa
          children: [
            Text('Email: ${widget.user?.email ?? "Chưa có thông tin"}'), // Hiển thị email
            Text('Tên: ${widget.user?.fullName ?? "Chưa có thông tin"}'), // Hiển thị tên đầy đủ
            Text('Vai trò: ${widget.user?.role ?? "Chưa có thông tin"}'), // Hiển thị vai trò
            const SizedBox(height: 20), // Khoảng cách giữa các phần tử
            ElevatedButton(
              onPressed: () async {
                await _dx(); // Gọi phương thức _dx khi nút bấm được nhấn
              },
              child: const Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }
}
