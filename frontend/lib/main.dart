import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:room_management_app/core/theme/app_theme.dart';
import 'package:room_management_app/presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase an toàn (tránh crash khi chạy thử nghiệm trên Web chưa cấu hình Options)
  try {
    await Firebase.initializeApp();

    // Bật tính năng lưu trữ Offline Cache của Cloud Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firebase chưa được cấu hình hoặc khởi tạo trên môi trường này: $e');
  }

  runApp(const RoomManagementApp());
}

class RoomManagementApp extends StatelessWidget {
  const RoomManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Phòng Trọ & Ki-ốt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
