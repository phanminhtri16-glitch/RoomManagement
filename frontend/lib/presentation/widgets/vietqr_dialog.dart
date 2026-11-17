import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:room_management_app/core/utils/vietqr_helper.dart';
import 'package:room_management_app/core/utils/currency_formatter.dart';
import 'package:room_management_app/data/models/invoice_model.dart';

class VietQrDialog extends StatelessWidget {
  final InvoiceModel invoice;
  final String bankBin;
  final String accountNumber;
  final String accountName;

  const VietQrDialog({
    super.key,
    required this.invoice,
    required this.bankBin,
    required this.accountNumber,
    required this.accountName,
  });

  @override
  Widget build(BuildContext context) {
    final transferContent = 'PHONG ${invoice.roomName} THANG ${invoice.billingMonth}';
    final qrData = VietQRHelper.generateRawEmvcoString(
      bankBin: bankBin,
      accountNumber: accountNumber,
      amount: invoice.totalAmount,
      description: transferContent,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mã Thanh Toán VietQR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 220.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              CurrencyFormatter.format(invoice.totalAmount),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F766E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chủ TK: $accountName - $accountNumber',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            Text(
              'Nội dung: $transferContent',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final message = '''
Kính gửi anh/chị phòng ${invoice.roomName},
Hóa đơn tiền phòng tháng ${invoice.billingMonth}:
- Tiền phòng: ${CurrencyFormatter.format(invoice.roomRentAmount)}
- Tiền điện (${invoice.electricUsage} kWh): ${CurrencyFormatter.format(invoice.electricTotal)}
- Tiền nước (${invoice.waterUsage} m³): ${CurrencyFormatter.format(invoice.waterTotal)}
- Tổng cộng: ${CurrencyFormatter.format(invoice.totalAmount)}

Thông tin chuyển khoản:
Ngân hàng: MBBank (hoặc ngân hàng của bạn)
Số tài khoản: $accountNumber
Chủ tài khoản: $accountName
Nội dung CK: $transferContent
                ''';
                Share.share(message, subject: 'Hóa đơn tiền phòng ${invoice.roomName}');
              },
              icon: const Icon(Icons.share),
              label: const Text('Gửi Hóa Đơn Qua Zalo / SMS'),
            ),
          ],
        ),
      ),
    );
  }
}
