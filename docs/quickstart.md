# Hướng Dẫn Khởi Chạy Dự Án (Quickstart Guide)

## 1. Yêu cầu môi trường
- Đã cài đặt **Flutter SDK** (bản 3.19 trở lên). Kiểm tra bằng lệnh: `flutter --version`
- Đã cài đặt **Android Studio** hoặc thiết bị điện thoại Android thật (bật USB Debugging).
- Tài khoản Google (để tạo dự án Firebase miễn phí).

---

## 2. Kết nối dự án với Firebase

### Bước 1: Tạo dự án Firebase
1. Truy cập [Firebase Console](https://console.firebase.google.com/) và tạo một Project mới (Ví dụ: `quan-ly-phong-tro`).
2. Kích hoạt các dịch vụ:
   - **Authentication**: Bật phương thức Email/Password hoặc Google.
   - **Cloud Firestore**: Chọn chế độ *Production* và chọn vị trí server `asia-southeast1` (Singapore) để có tốc độ nhanh nhất tại Việt Nam.
   - **Firebase Storage**: Bật dịch vụ lưu trữ ảnh.

### Bước 2: Liên kết với Flutter qua FlutterFire CLI
Chạy lệnh sau tại thư mục `frontend/`:
```bash
cd frontend
dart pub global activate flutterfire_cli
flutterfire configure
```
Lệnh này sẽ tự động sinh file `lib/firebase_options.dart` và liên kết với App Android của bạn.

---

## 3. Triển khai Quy tắc bảo mật (Security Rules)
Từ thư mục gốc dự án:
```bash
cd backend
npm install -g firebase-tools
firebase login
firebase use --add  # Chọn project vừa tạo ở Bước 1
firebase deploy --only firestore:rules,storage:rules
```

---

## 4. Chạy ứng dụng trên máy ảo hoặc điện thoại Android
Từ thư mục `frontend/`:
```bash
flutter pub get
flutter run
```
