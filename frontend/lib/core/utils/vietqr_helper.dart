/// Tiện ích sinh chuỗi mã VietQR chuẩn Napas 247 (EMVCo QR Code)
/// Hoạt động hoàn toàn Offline ngay trên điện thoại không cần gọi API ngoài.
class VietQRHelper {
  /// Tạo link ảnh VietQR nhanh (khi có mạng)
  static String generateQuickImageUrl({
    required String bankBin,
    required String accountNumber,
    required num amount,
    required String description,
    String template = 'compact2',
  }) {
    final cleanDesc = Uri.encodeComponent(description);
    return 'https://img.vietqr.io/image/$bankBin-$accountNumber-$template.png?amount=${amount.toInt()}&addInfo=$cleanDesc';
  }

  /// Sinh chuỗi dữ liệu EMVCo thô để render trực tiếp bằng QrImageView (Offline 100%)
  static String generateRawEmvcoString({
    required String bankBin,
    required String accountNumber,
    required num amount,
    required String description,
  }) {
    // Tag 00: Payload Format Indicator
    final tag00 = _buildTag('00', '01');
    // Tag 01: Point of Initiation Method (12: Dynamic QR code)
    final tag01 = _buildTag('01', '12');

    // Tag 38: Merchant Account Information (NAPAS)
    // 00: GUID (A000000727)
    final subTag00 = _buildTag('00', 'A000000727');
    // 01: Beneficiary Bank & Account (00: Bank BIN, 01: Account Number)
    final bankSub00 = _buildTag('00', bankBin);
    final bankSub01 = _buildTag('01', accountNumber);
    final subTag01 = _buildTag('01', '$bankSub00$bankSub01');
    // 02: Service Code (QRIBFTTC: Chuyển tiền nhanh Napas247 tới tài khoản)
    final subTag02 = _buildTag('02', 'QRIBFTTC');
    final tag38 = _buildTag('38', '$subTag00$subTag01$subTag02');

    // Tag 53: Transaction Currency (704 = VND)
    final tag53 = _buildTag('53', '704');
    // Tag 54: Transaction Amount
    final tag54 = _buildTag('54', amount.toInt().toString());
    // Tag 58: Country Code
    final tag58 = _buildTag('58', 'VN');

    // Tag 62: Additional Data Field (08: Nội dung chuyển khoản)
    final subTag6208 = _buildTag('08', description);
    final tag62 = _buildTag('62', subTag6208);

    // Ghép chuỗi trước khi tính CRC
    final rawDataWithoutCrc = '$tag00$tag01$tag38$tag53$tag54$tag58$tag62' '6304';
    final crc = _crc16Ccitt(rawDataWithoutCrc);

    return '$rawDataWithoutCrc$crc';
  }

  static String _buildTag(String tag, String value) {
    final length = value.length.toString().padLeft(2, '0');
    return '$tag$length$value';
  }

  /// Thuật toán tính mã kiểm tra CRC-16/CCITT-FALSE
  static String _crc16Ccitt(String data) {
    int crc = 0xFFFF;
    for (int i = 0; i < data.length; i++) {
      final byte = data.codeUnitAt(i);
      crc ^= (byte << 8);
      for (int j = 0; j < 8; j++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
