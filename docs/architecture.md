# Kiến Trúc Hệ Thống (System Architecture)

Hệ thống quản lý phòng trọ và ki-ốt cá nhân được thiết kế theo mô hình **Client-First & BaaS (Backend-as-a-Service)** với khả năng hoạt động ngoại tuyến (Offline-First) và thanh toán bán tự động qua mã VietQR chuẩn Napas 247.

```mermaid
flowchart TD
    subgraph MobileClient ["Flutter Mobile App (Android)"]
        UI["Presentation Layer\n(UI Screens & Widgets)"]
        BLOC["State Management\n(BLoC / Cubits)"]
        REPO["Repository Layer\n(Offline Sync & Cache)"]
        VIETQR["VietQR Engine\n(EMVCo Napas247 Generator)"]
    end

    subgraph FirebaseCloud ["Firebase Cloud Infrastructure (0đ Spark Plan)"]
        AUTH["Firebase Auth\n(Xác thực tài khoản chủ)"]
        FIRESTORE[("Cloud Firestore\n(NoSQL Database & Offline Cache)")]
        STORAGE[("Firebase Storage\n(Ảnh công tơ điện nước & CCCD)")]
        FUNCTIONS["Cloud Functions\n(Tác vụ tự động hàng tháng)"]
    end

    subgraph BankingApp ["Khách Thuê Quét Mã"]
        APP["App Ngân Hàng\n(Vietcombank, MB, Techcombank, Momo, etc.)"]
    end

    UI --> BLOC
    BLOC --> REPO
    REPO <-->|Tự động đồng bộ Realtime & Offline| FIRESTORE
    REPO -->|Tải ảnh chụp đồng hồ| STORAGE
    UI --> VIETQR
    VIETQR -->|Xuất mã QR & Chia sẻ Zalo| APP
    AUTH -.->|Phân quyền theo Owner UID| FIRESTORE
    FUNCTIONS -.->|Cron ngày 01 tạo hóa đơn nháp| FIRESTORE
```

---

## Các luồng nghiệp vụ cốt lõi

### 1. Luồng hoạt động ngoại tuyến (Offline-First Flow)
1. Chủ trọ cầm điện thoại xuống tầng hầm/góc khuất mất sóng 4G/WiFi.
2. Mở màn hình **Ghi điện nước** -> Nhập số điện/nước mới, chụp ảnh đồng hồ.
3. SDK `cloud_firestore` lập tức ghi dữ liệu vào bộ nhớ đệm cục bộ (Local Cache) của điện thoại và hiển thị trạng thái thành công ngay lập tức.
4. Khi chủ trọ quay lại khu vực có sóng WiFi/4G, SDK Firebase tự động đẩy các thay đổi lên máy chủ Cloud Firestore mà không yêu cầu bất kỳ thao tác thủ công nào.

### 2. Luồng thanh toán VietQR bán tự động (Semi-Automated Payment)
1. Sau khi chốt số điện nước, hệ thống tự động tính thành tiền hóa đơn.
2. Chủ trọ bấm nút **Mã QR** trên hóa đơn:
   - Module `VietQRHelper` tự động biên dịch thông tin số tài khoản, số tiền và cú pháp (`PHONG [TenPhong] THANG [Thang]`) thành chuỗi chuẩn EMVCo Napas.
   - Ứng dụng render mã QR ngay trên màn hình mà không cần gọi API ngân hàng ngoài.
3. Chủ trọ bấm **Gửi qua Zalo**: Tin nhắn văn bản chi tiết tiền phòng + mã QR được chia sẻ trực tiếp tới khách thuê.
4. Khi nhận được tiền báo về SMS/App ngân hàng, chủ trọ chỉ cần bấm nút **Xác nhận đã nhận đủ tiền** trên ứng dụng để hóa đơn chuyển sang trạng thái `Đã thanh toán`.
