import 'package:cloud_firestore/cloud_firestore.dart';

/// Đại diện cho thông tin khách thuê (Người đại diện ký hợp đồng)
class TenantModel {
  final String id;
  final String ownerId;
  final String roomId;
  final String roomName; // Tên phòng khách đang thuê / đã thuê
  final String fullName;
  final String phone;
  final String idCardNumber; // Số CCCD
  final String? idCardFrontUrl; // Ảnh chụp CCCD mặt trước
  final String? idCardBackUrl; // Ảnh chụp CCCD mặt sau
  final String? contractPhotoUrl; // Ảnh chụp hợp đồng thuê
  final DateTime startDate; // Ngày bắt đầu thuê
  final DateTime? endDate; // Ngày kết thúc hợp đồng dự kiến
  final DateTime? checkoutDate; // Ngày thực tế trả phòng
  final int depositPaid; // Số tiền cọc đã đóng
  final int numberOfResidents; // Số người ở
  final List<String> vehiclePlates; // Danh sách biển số xe máy
  final String note;
  final String status; // 'ACTIVE' (Đang thuê) hoặc 'CHECKED_OUT' (Đã trả phòng)

  TenantModel({
    required this.id,
    required this.ownerId,
    required this.roomId,
    this.roomName = '',
    required this.fullName,
    required this.phone,
    required this.idCardNumber,
    this.idCardFrontUrl,
    this.idCardBackUrl,
    this.contractPhotoUrl,
    required this.startDate,
    this.endDate,
    this.checkoutDate,
    required this.depositPaid,
    this.numberOfResidents = 1,
    this.vehiclePlates = const [],
    this.note = '',
    this.status = 'ACTIVE',
  });

  bool get isActive => status == 'ACTIVE';
  bool get isCheckedOut => status == 'CHECKED_OUT';

  TenantModel copyWith({
    String? id,
    String? ownerId,
    String? roomId,
    String? roomName,
    String? fullName,
    String? phone,
    String? idCardNumber,
    String? idCardFrontUrl,
    String? idCardBackUrl,
    String? contractPhotoUrl,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? checkoutDate,
    int? depositPaid,
    int? numberOfResidents,
    List<String>? vehiclePlates,
    String? note,
    String? status,
  }) {
    return TenantModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      idCardFrontUrl: idCardFrontUrl ?? this.idCardFrontUrl,
      idCardBackUrl: idCardBackUrl ?? this.idCardBackUrl,
      contractPhotoUrl: contractPhotoUrl ?? this.contractPhotoUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      checkoutDate: checkoutDate ?? this.checkoutDate,
      depositPaid: depositPaid ?? this.depositPaid,
      numberOfResidents: numberOfResidents ?? this.numberOfResidents,
      vehiclePlates: vehiclePlates ?? this.vehiclePlates,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'roomId': roomId,
      'roomName': roomName,
      'fullName': fullName,
      'phone': phone,
      'idCardNumber': idCardNumber,
      'idCardFrontUrl': idCardFrontUrl,
      'idCardBackUrl': idCardBackUrl,
      'contractPhotoUrl': contractPhotoUrl,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'checkoutDate': checkoutDate != null ? Timestamp.fromDate(checkoutDate!) : null,
      'depositPaid': depositPaid,
      'numberOfResidents': numberOfResidents,
      'vehiclePlates': vehiclePlates,
      'note': note,
      'status': status,
    };
  }

  factory TenantModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TenantModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      roomId: data['roomId'] ?? '',
      roomName: data['roomName'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      idCardNumber: data['idCardNumber'] ?? '',
      idCardFrontUrl: data['idCardFrontUrl'],
      idCardBackUrl: data['idCardBackUrl'],
      contractPhotoUrl: data['contractPhotoUrl'],
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      checkoutDate: (data['checkoutDate'] as Timestamp?)?.toDate(),
      depositPaid: data['depositPaid'] ?? 0,
      numberOfResidents: data['numberOfResidents'] ?? 1,
      vehiclePlates: List<String>.from(data['vehiclePlates'] ?? []),
      note: data['note'] ?? '',
      status: data['status'] ?? 'ACTIVE',
    );
  }
}
