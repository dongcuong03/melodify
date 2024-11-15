import 'package:flutter/material.dart';
class AdminManagerAlbumScreen extends StatefulWidget {
  const AdminManagerAlbumScreen({super.key});

  @override
  State<AdminManagerAlbumScreen> createState() => _AdminManagerAlbumScreenState();
}

class _AdminManagerAlbumScreenState extends State<AdminManagerAlbumScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
              'Quản lý album'
          ),
        )
    );
  }
}
