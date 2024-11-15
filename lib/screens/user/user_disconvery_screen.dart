import 'package:flutter/material.dart';
class UserDisconveryScreen extends StatefulWidget {
  const UserDisconveryScreen({super.key});

  @override
  State<UserDisconveryScreen> createState() => _UserDisconveryScreenState();
}

class _UserDisconveryScreenState extends State<UserDisconveryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Khám phá')),
      body: const Center(
        child: Text('Khám phá'),
      ),
    );
  }
}
