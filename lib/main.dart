import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/dfareporting/v4.dart';
import 'package:melodify/providers/firebase_auth_provider.dart';
import 'package:melodify/providers/genre_provider.dart';
import 'package:melodify/providers/google_drive_provider.dart';
import 'package:melodify/providers/song_provider.dart';
import 'package:melodify/screens/admin/song/admin_add_song_screen.dart';
import 'package:melodify/screens/intro_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseAuthProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()),
        ChangeNotifierProvider(create: (_) => GoogleDriveProvider()),
        ChangeNotifierProvider(create: (_) => SongProvider()),
      ],
      child: const MaterialApp(
        home: IntroScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
