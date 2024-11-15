import 'package:flutter/material.dart';
import 'package:melodify/models/user_model.dart';
import 'package:melodify/screens/user/user_disconvery_screen.dart';
import 'package:melodify/screens/user/user_home_screen.dart';
import 'package:melodify/screens/user/user_library_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    // Tạo danh sách _page trong build để sử dụng widget.user
    final List<Widget> _page = [
      UserHomeScreen(user: widget.user), // Truyền thông tin user vào đây
      const UserDisconveryScreen(),
      const UserLibraryScreen(),
    ];

    return Scaffold(
      body: _page[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
        selectedItemColor: const Color(0xff005609),
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
