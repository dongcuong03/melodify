import 'package:flutter/material.dart';
class AdminManagerCommentScreen extends StatefulWidget {
  const AdminManagerCommentScreen({super.key});

  @override
  State<AdminManagerCommentScreen> createState() => _AdminManagerCommentScreenState();
}

class _AdminManagerCommentScreenState extends State<AdminManagerCommentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
              'Quản lý bình luận'
          ),
        )
    );
  }
}
