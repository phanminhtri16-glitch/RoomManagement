import 'package:flutter/material.dart';
import 'package:room_management_app/core/constants/app_constants.dart';
import 'package:room_management_app/core/utils/currency_formatter.dart';
import 'package:room_management_app/data/models/invoice_model.dart';
import 'package:room_management_app/presentation/widgets/vietqr_dialog.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  // Danh sách hóa đơn mẫu
  final List<InvoiceModel> _invoices = [
    InvoiceModel(
      id: 'inv_1',
      ownerId: 'user_1',
      propertyId: 'prop_1',
      roomId: '1',
      roomName: 'Ki-ốt K01',
      tenantName: 'Nguyễn Văn An',
      tenantPhone: '0912345678',
      billingMonth: '2026-11',
      status: AppConstants.invoicePending,
      roomRentAmount: 6500000,
      electricOldNumber: 1420,
      electricNewNumber: 1560,
      electricUnitPrice: 4000,
      waterOldNumber: 85,
      waterNewNumber: 95,
      waterUnitPrice: 25000,
      totalAmount: 7310000,
      createdAt: DateTime.now(),
    ),
    InvoiceModel(
      id: 'inv_2',
      ownerId: 'user_1',
      propertyId: 'prop_1',
      roomId: '2',
      roomName: 'Phòng 101',
      tenantName: 'Trần Thị Bích',
      tenantPhone: '0987654321',
      billingMonth: '2026-11',
      status: AppConstants.invoicePaid,
      roomRentAmount: 3200000,
      electricOldNumber: 840,
      electricNewNumber: 910,
      electricUnitPrice: 3500,
      waterOldNumber: 42,
      waterNewNumber: 47,
      waterUnitPrice: 20000,
      totalAmount: 3545000,
      createdAt: DateTime.now(),
      paidAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hóa Đơn Thu Tiền', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _invoices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final invoice = _invoices[index];
          final isPaid = invoice.status == AppConstants.invoicePaid;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hóa đơn: ${invoice.roomName}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      _buildInvoiceStatusChip(invoice.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Khách thuê: ${invoice.tenantName ?? "Chưa rõ"} - ${invoice.tenantPhone ?? ""}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tổng tiền cần thanh toán', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.format(invoice.totalAmount),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 40),
                          backgroundColor: const Color(0xFF0F766E),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => VietQrDialog(
                              invoice: invoice,
                              bankBin: '970422', // MBBank
                              accountNumber: '09123456789',
                              accountName: 'NGUYEN VAN CHU TRO',
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code_2, size: 18),
                        label: const Text('Mã QR'),
                      ),
                    ],
                  ),
                  if (!isPaid) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        foregroundColor: Colors.green.shade700,
                        side: BorderSide(color: Colors.green.shade300),
                      ),
                      onPressed: () {
                        setState(() {
                          _invoices[index] = InvoiceModel(
                            id: invoice.id,
                            ownerId: invoice.ownerId,
                            propertyId: invoice.propertyId,
                            roomId: invoice.roomId,
                            roomName: invoice.roomName,
                            tenantName: invoice.tenantName,
                            tenantPhone: invoice.tenantPhone,
                            billingMonth: invoice.billingMonth,
                            status: AppConstants.invoicePaid,
                            roomRentAmount: invoice.roomRentAmount,
                            electricOldNumber: invoice.electricOldNumber,
                            electricNewNumber: invoice.electricNewNumber,
                            electricUnitPrice: invoice.electricUnitPrice,
                            waterOldNumber: invoice.waterOldNumber,
                            waterNewNumber: invoice.waterNewNumber,
                            waterUnitPrice: invoice.waterUnitPrice,
                            totalAmount: invoice.totalAmount,
                            createdAt: invoice.createdAt,
                            paidAt: DateTime.now(),
                          );
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã xác nhận thanh toán phòng ${invoice.roomName}!')),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Xác nhận đã nhận đủ tiền'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvoiceStatusChip(String status) {
    final isPaid = status == AppConstants.invoicePaid;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.withOpacity(0.12) : Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPaid ? 'Đã thanh toán' : 'Chờ thu tiền',
        style: TextStyle(
          color: isPaid ? Colors.green.shade800 : Colors.amber.shade900,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
