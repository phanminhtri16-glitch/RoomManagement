# Room & Kiosk Management System (Quản Lý Phòng Trọ & Ki-ốt)

Hệ thống quản lý phòng trọ và ki-ốt cá nhân sử dụng **Flutter** và **Firebase**.

## Cấu trúc dự án

```text
RoomManagement/
├── mobile/                  # Ứng dụng di động Flutter (Android)
│   ├── lib/
│   │   ├── core/            # Theme, constants, utilities (VietQR generator, formatters)
│   │   ├── data/            # Models, Repositories, Data sources (Firestore, Storage)
│   │   ├── domain/          # Entities, Use cases, Business rules
│   │   └── presentation/    # Màn hình (UI), Widgets, BLoC/State Management
│   ├── assets/              # Icons, fonts, images
│   └── pubspec.yaml         # Cấu hình thư viện Flutter
│
├── backend/                 # Firebase Cloud Backend & Rules
│   ├── functions/           # Cloud Functions (Node.js/TypeScript)
│   │   ├── src/             # Tự động hóa (chốt tiền hàng tháng, tiện ích hóa đơn)
│   │   └── package.json
│   ├── firestore.rules      # Quy tắc bảo mật dữ liệu Firestore
│   ├── firestore.indexes.json# Định nghĩa Index truy vấn
│   ├── storage.rules        # Quy tắc bảo mật lưu trữ ảnh (CCCD, công tơ)
│   └── firebase.json        # Cấu hình dịch vụ Firebase
│
└── docs/                    # Tài liệu đặc tả và hướng dẫn
    ├── architecture.md      # Thiết kế kiến trúc tổng thể
    └── firestore_schema.md  # Đặc tả dữ liệu NoSQL chi tiết
```
