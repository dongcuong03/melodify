import 'package:flutter/material.dart';
class UserLibraryScreen extends StatefulWidget {
  const UserLibraryScreen({super.key});

  @override
  State<UserLibraryScreen> createState() => _UserLibraryScreenState();
}

class _UserLibraryScreenState extends State<UserLibraryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thư viện')),
      body: const Center(
        child: Text('Thư viện'),
      ),
    );
  }
}
