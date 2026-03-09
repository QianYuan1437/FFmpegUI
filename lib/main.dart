import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FFmpegUIApp());
}

class FFmpegUIApp extends StatelessWidget {
  const FFmpegUIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FFmpeg视频转换工具',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Microsoft YaHei',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(fontWeight: FontWeight.w500),
          bodySmall: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
