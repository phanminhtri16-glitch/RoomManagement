# Thiết Kế Cơ Sở Dữ Liệu NoSQL (Cloud Firestore)

Hệ thống quản lý phòng trọ và ki-ốt cá nhân sử dụng Firestore với cấu trúc phân cấp Document/Collection tối ưu cho truy vấn nhanh và hoạt động Offline Cache.

---

## 1. Collection `properties` (Dãy trọ / Tòa nhà / Cụm ki-ốt)
Mỗi document đại diện cho một địa điểm kinh doanh của chủ trọ.

| Trường | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | String | Document ID (tự sinh) |
| `ownerId` | String | UID của chủ trọ (Firebase Auth) |
| `name` | String | Tên khu (VD: "Dãy trọ Tân Bình", "Khu Ki-ốt Chợ Chiều") |
| `address` | String | Địa chỉ cụ thể |
| `electricPrice`| Number | Đơn giá điện mặc định (VNĐ/kWh, ví dụ: 3.500) |
| `waterPrice` | Number | Đơn giá nước mặc định (VNĐ/m³ hoặc VNĐ/người) |
| `garbageFee` | Number | Phí thu gom rác cố định hàng tháng (VNĐ) |
| `internetFee`| Number | Phí Wifi hàng tháng (VNĐ) |
| `createdAt` | Timestamp | Thời điểm tạo |

---

## 2. Collection `rooms` (Phòng trọ / Ki-ốt)
Mỗi document là một đơn vị cho thuê (phòng sinh hoạt hoặc mặt bằng ki-ốt).

| Trường | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | String | Document ID |
| `ownerId` | String | UID của chủ trọ |
| `propertyId`| String | ID của khu/dãy tương ứng |
| `name` | String | Tên/số phòng (VD: "Phòng 102", "Ki-ốt K01") |
| `type` | String | `ROOM` (Phòng trọ) hoặc `KIOSK` (Ki-ốt kinh doanh) |
| `status` | String | `AVAILABLE` (Trống), `OCCUPIED` (Đang thuê), `MAINTENANCE` |
| `baseRentPrice`| Number | Giá thuê định kỳ (VNĐ) |
| `depositAmount`| Number | Số tiền đặt cọc (VNĐ) |
| `billingCycleMonths`| Number | Kỳ thanh toán: 1 (phòng trọ), 3/6/12 (ki-ốt) |
| `currentTenantId` | String? | ID khách thuê hiện tại (nếu đang thuê) |
| `currentTenantName` | String? | Tên khách thuê để hiển thị nhanh |
| `currentTenantPhone`| String? | SĐT khách thuê |
| `lastElectricNumber`| Number | Chỉ số điện chốt gần nhất |
| `lastWaterNumber` | Number | Chỉ số nước chốt gần nhất |
| `updatedAt` | Timestamp | Thời gian cập nhật |

---

## 3. Collection `tenants` (Khách thuê)
Lưu thông tin nhân thân và giấy tờ pháp lý để chủ trọ làm thủ tục tạm trú.

| Trường | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | String | Document ID |
| `ownerId` | String | UID chủ trọ |
| `roomId` | String | ID phòng đang thuê |
| `fullName` | String | Họ và tên khách thuê đại diện |
| `phone` | String | Số điện thoại liên hệ |
| `idCardNumber` | String | Số Căn cước công dân (CCCD) |
| `idCardFrontUrl` | String? | Link ảnh mặt trước CCCD (Firebase Storage) |
| `idCardBackUrl` | String? | Link ảnh mặt sau CCCD (Firebase Storage) |
| `contractPhotoUrl` | String? | Link ảnh chụp hợp đồng thuê |
| `startDate` | Timestamp | Ngày bắt đầu vào ở / thuê |
| `depositPaid` | Number | Tiền cọc đã nạp thực tế |
| `numberOfResidents` | Number | Số lượng người cư trú |
| `vehiclePlates` | Array<String> | Danh sách biển số xe máy |
| `note` | String | Ghi chú thêm |

---

## 4. Collection `invoices` (Hóa đơn hàng tháng)
Lưu trữ hóa đơn phát sinh hàng tháng kèm bằng chứng chỉ số điện nước.

| Trường | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | String | Document ID |
| `ownerId` | String | UID chủ trọ |
| `propertyId` | String | ID dãy trọ |
| `roomId` | String | ID phòng |
| `roomName` | String | Tên phòng/ki-ốt |
| `billingMonth` | String | Tháng hóa đơn (Định dạng "YYYY-MM", VD: "2026-11") |
| `status` | String | `DRAFT`, `PENDING` (Chờ thu), `PAID` (Đã thu) |
| `roomRentAmount` | Number | Tiền phòng |
| `electricOldNumber`| Number | Số điện đầu kỳ |
| `electricNewNumber`| Number | Số điện cuối kỳ |
| `electricUnitPrice`| Number | Đơn giá điện (đ/kWh) |
| `electricPhotoUrl` | String? | Ảnh chụp công tơ điện |
| `waterOldNumber` | Number | Số nước đầu kỳ |
| `waterNewNumber` | Number | Số nước cuối kỳ |
| `waterUnitPrice` | Number | Đơn giá nước (đ/m³) |
| `waterPhotoUrl` | String? | Ảnh chụp đồng hồ nước |
| `garbageFee` | Number | Phí vệ sinh/rác |
| `internetFee` | Number | Phí Wifi |
| `otherFee` | Number | Phí phát sinh (nếu có) |
| `totalAmount` | Number | Tổng cộng tiền phải trả |
| `createdAt` | Timestamp | Thời điểm tạo |
| `paidAt` | Timestamp? | Thời điểm chủ bấm xác nhận đã thu tiền |
