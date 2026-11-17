import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:room_management_app/core/constants/app_constants.dart';

/// Đại diện cho hóa đơn thu tiền hàng tháng (Tiền phòng, điện, nước, dịch vụ)
class InvoiceModel {
  final String id;
  final String ownerId;
  final String propertyId;
  final String roomId;
  final String roomName;
  final String? tenantName;
  final String? tenantPhone;
  final String billingMonth; // Định dạng "YYYY-MM", VD: "2026-11"
  final String status; // DRAFT, PENDING, PAID, OVERDUE

  // Chi tiết tiền phòng
  final int roomRentAmount;

  // Chi tiết tiền điện
  final int electricOldNumber;
  final int electricNewNumber;
  final int electricUnitPrice;
  final String? electricPhotoUrl; // Ảnh chụp công tơ điện làm bằng chứng

  // Chi tiết tiền nước
  final int waterOldNumber;
  final int waterNewNumber;
  final int waterUnitPrice;
  final String? waterPhotoUrl; // Ảnh chụp đồng hồ nước

  // Các loại phí dịch vụ phát sinh
  final int garbageFee;
  final int internetFee;
  final int otherFee;
  final String otherFeeNote;

  final int totalAmount;
  final DateTime createdAt;
  final DateTime? paidAt;

  InvoiceModel({
    required this.id,
    required this.ownerId,
    required this.propertyId,
    required this.roomId,
    required this.roomName,
    this.tenantName,
    this.tenantPhone,
    required this.billingMonth,
    required this.status,
    required this.roomRentAmount,
    this.electricOldNumber = 0,
    this.electricNewNumber = 0,
    this.electricUnitPrice = 3500,
    this.electricPhotoUrl,
    this.waterOldNumber = 0,
    this.waterNewNumber = 0,
    this.waterUnitPrice = 20000,
    this.waterPhotoUrl,
    this.garbageFee = 0,
    this.internetFee = 0,
    this.otherFee = 0,
    this.otherFeeNote = '',
    required this.totalAmount,
    required this.createdAt,
    this.paidAt,
  });

  int get electricUsage => (electricNewNumber - electricOldNumber).clamp(0, 999999);
  int get electricTotal => electricUsage * electricUnitPrice;

  int get waterUsage => (waterNewNumber - waterOldNumber).clamp(0, 999999);
  int get waterTotal => waterUsage * waterUnitPrice;

  bool get isPaid => status == AppConstants.invoicePaid;

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'propertyId': propertyId,
      'roomId': roomId,
      'roomName': roomName,
      'tenantName': tenantName,
      'tenantPhone': tenantPhone,
      'billingMonth': billingMonth,
      'status': status,
      'roomRentAmount': roomRentAmount,
      'electricOldNumber': electricOldNumber,
      'electricNewNumber': electricNewNumber,
      'electricUnitPrice': electricUnitPrice,
      'electricPhotoUrl': electricPhotoUrl,
      'waterOldNumber': waterOldNumber,
      'waterNewNumber': waterNewNumber,
      'waterUnitPrice': waterUnitPrice,
      'waterPhotoUrl': waterPhotoUrl,
      'garbageFee': garbageFee,
      'internetFee': internetFee,
      'otherFee': otherFee,
      'otherFeeNote': otherFeeNote,
      'totalAmount': totalAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
    };
  }

  factory InvoiceModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return InvoiceModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      propertyId: data['propertyId'] ?? '',
      roomId: data['roomId'] ?? '',
      roomName: data['roomName'] ?? '',
      tenantName: data['tenantName'],
      tenantPhone: data['tenantPhone'],
      billingMonth: data['billingMonth'] ?? '',
      status: data['status'] ?? AppConstants.invoiceDraft,
      roomRentAmount: data['roomRentAmount'] ?? 0,
      electricOldNumber: data['electricOldNumber'] ?? 0,
      electricNewNumber: data['electricNewNumber'] ?? 0,
      electricUnitPrice: data['electricUnitPrice'] ?? 3500,
      electricPhotoUrl: data['electricPhotoUrl'],
      waterOldNumber: data['waterOldNumber'] ?? 0,
      waterNewNumber: data['waterNewNumber'] ?? 0,
      waterUnitPrice: data['waterUnitPrice'] ?? 20000,
      waterPhotoUrl: data['waterPhotoUrl'],
      garbageFee: data['garbageFee'] ?? 0,
      internetFee: data['internetFee'] ?? 0,
      otherFee: data['otherFee'] ?? 0,
      otherFeeNote: data['otherFeeNote'] ?? '',
      totalAmount: data['totalAmount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
    );
  }
}
