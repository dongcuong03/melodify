import 'package:flutter/material.dart';
import 'package:melodify/models/user_model.dart';
import 'package:melodify/screens/user/user_disconvery_screen.dart';
import 'package:melodify/screens/user/home/user_home_screen.dart';
import 'package:melodify/screens/user/user_library_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/firebase_auth_provider.dart';
import '../auth/login_screen.dart';

class UserMainScreen extends StatefulWidget {
  final UserModel? user;
  const UserMainScreen({Key? key, this.user}) : super(key: key);

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _selectedIndex = 0; // Chỉ số của tab đang được chọn

  // Hàm sử lý khi người dùng nhấn vào các item trên BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
    // Tạo danh sách _page trong build để sử dụng widget.user
    final List<Widget> _page = [
      UserHomeScreen(), // Truyền thông tin user vào đây
      const UserDisconveryScreen(),
      const UserLibraryScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFF121212),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                widget.user?.fullName ?? 'Unknown',
                style: const TextStyle(color: Colors.white),
              ),
              accountEmail: Text(
                widget.user?.email ?? 'No Email',
                style: const TextStyle(color: Colors.white),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/anh_user.png'),
              ),
              decoration: const BoxDecoration(color: Color(0xff005609)),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white),
              title: const Text('Lịch sử nghe', style: TextStyle(color: Colors.white)),
              onTap: () {
                _onItemTapped(0); // Chuyển đến trang chủ
                Navigator.pop(context); // Đóng menu
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.white),
              title: const Text('Tải xuống', style: TextStyle(color: Colors.white)),
              onTap: () {
                _onItemTapped(1); // Chuyển đến Khám phá
                Navigator.pop(context); // Đóng menu
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Cài đặt', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Thêm logic cho cài đặt nếu cần
                Navigator.pop(context); // Đóng menu
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
              onTap: () {
                _dx();
              },
            ),
          ],
        ),
      ),
      body: _page[_selectedIndex],
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.black87,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF121212), // Màu bóng đậm hơn
                  offset: Offset(0, -4), // Điều chỉnh vị trí bóng lên trên
                  blurRadius: 8, // Độ mờ của bóng
                ),
              ],
            ),
            child: BottomNavigationBar(
              elevation: 10, // Tạo hiệu ứng nổi lên
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: 'Khám phá',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_music_rounded),
                  label: 'Thư viện',
                ),
              ],
              selectedItemColor: const Color(0xff00ff7f),
              unselectedItemColor: Colors.white,
              backgroundColor: Color(0xFF121212),
              type: BottomNavigationBarType.fixed,
            ),
          ),
        )


    );
  }
}
