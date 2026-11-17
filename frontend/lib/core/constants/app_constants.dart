class AppConstants {
  // Loại hình cho thuê
  static const String typeRoom = 'ROOM';     // Phòng trọ sinh hoạt
  static const String typeKiosk = 'KIOSK';   // Ki-ốt mặt bằng kinh doanh

  // Trạng thái phòng / ki-ốt
  static const String statusAvailable = 'AVAILABLE'; // Phòng trống
  static const String statusOccupied = 'OCCUPIED';   // Đang thuê
  static const String statusMaintenance = 'MAINTENANCE'; // Đang sửa chữa

  // Trạng thái hóa đơn
  static const String invoiceDraft = 'DRAFT';       // Bản nháp chưa chốt
  static const String invoicePending = 'PENDING';   // Đã chốt, chờ khách đóng tiền
  static const String invoicePaid = 'PAID';         // Đã thanh toán xong
  static const String invoiceOverdue = 'OVERDUE';   // Quá hạn

  // Đơn giá mặc định (chủ trọ có thể đổi trong settings)
  static const int defaultElectricRate = 3500; // 3.500 đ / kWh
  static const int defaultWaterRatePerCube = 20000; // 20.000 đ / m³
  static const int defaultWaterRatePerPerson = 50000; // 50.000 đ / người
  static const int defaultGarbageFee = 30000; // 30.000 đ / phòng
  static const int defaultWifiFee = 50000; // 50.000 đ / phòng

  // Ngân hàng nhận thanh toán VietQR (Cấu hình tài khoản chủ trọ)
  static const String defaultBankBin = '970422'; // Ví dụ: MBBank (970422), Vietcombank (970436), etc.
}
