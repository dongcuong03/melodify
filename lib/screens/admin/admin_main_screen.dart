import 'package:flutter/material.dart';
import 'package:melodify/screens/admin/home/admin_home_screen.dart';
import 'package:melodify/screens/admin/album/admin_manager_album_screen.dart';
import 'package:melodify/screens/admin/comment/admin_manager_comment_screen.dart';
import 'package:melodify/screens/admin/genre/admin_manager_genre_screen.dart';
import 'package:melodify/screens/admin/song/admin_manager_song_screen.dart';
import 'package:melodify/screens/admin/statistical_report/admin_statistical_report_screen.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/firebase_auth_provider.dart';
import '../auth/login_screen.dart';

class AdminMainScreen extends StatefulWidget {
  final UserModel? user;

  const AdminMainScreen({Key? key, this.user}) : super(key: key);

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0; // Chỉ số của mục đang được chọn trong menu

  // Hàm chuyển đổi giữa các màn hình
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //hàm dang xuat
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
    List<Widget> _pages = [
      // Các màn hình sẽ hiển thị khi chọn các mục khác nhau
      AdminHomeScreen(),
      AdminManagerSongScreen(),
      AdminManagerAlbumScreen(),
      AdminManagerGenreScreen(),
      AdminManagerCommentScreen(),
      AdminStatisticalReportScreen()
    ];

    // Danh sách tiêu đề tương ứng với mỗi trang
    List<String> _titles = [
      'Trang Chủ',
      'Quản Lý Bài Hát',
      'Quản Lý Album',
      'Quản Lý Thể Loại',
      'Quản Lý Bình Luận',
      'Báo Cáo Thống Kê'
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true, // Tự động thêm nút menu nếu có Drawer
        elevation: 0, // Tùy chọn để bỏ bóng cho AppBar
        title: null, // Đặt title là null để tránh sự can thiệp của mặc định AppBar title
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 28.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Căn giữa tiêu đề
            children: [
              Center(
                child: Text(
                  _titles[_selectedIndex], // Cập nhật tiêu đề theo _selectedIndex
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(widget.user?.fullName ?? 'Unknown'),
              accountEmail: Text(widget.user?.email ?? 'No Email'),
              currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/anh_admin.jpg')),
              decoration: const BoxDecoration(color: Color(0xFF005609)),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: const Text('Trang chủ'),
              onTap: () {
                _onItemTapped(0);  // Chuyển đến trang chủ
                Navigator.pop(context);  // Đóng Drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.music_note),
              title: const Text('Quản lý bài hát'),
              onTap: () {
                _onItemTapped(1);  // Chuyển đến quản lý bài hát
                Navigator.pop(context);  // Đóng Drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.album),
              title: const Text('Quản lý album'),
              onTap: () {
                _onItemTapped(2);  // Chuyển đến quản lý album
                Navigator.pop(context);  // Đóng Drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: const Text('Quản lý thể loại'),
              onTap: () {
                _onItemTapped(3);  // Chuyển đến quản lý thể loại
                Navigator.pop(context);  // Đóng Drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.comment),
              title: const Text('Quản lý bình luận'),
              onTap: () {
                _onItemTapped(4);  // Chuyển đến quản lý bình luận
                Navigator.pop(context);  // Đóng Drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Báo cáo thống kê'),
              onTap: () {
                _onItemTapped(5);  // Chuyển đến báo cáo thống kê
                Navigator.pop(context);  // Đóng Drawer
              },
            ),
            const Divider(), // Đường phân cách
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: _dx, // Gọi hàm đăng xuất
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],  // Hiển thị màn hình dựa trên mục được chọn
    );
  }
}
