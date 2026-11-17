import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:room_management_app/core/constants/app_constants.dart';

/// Đại diện cho một phòng trọ sinh hoạt hoặc một ki-ốt kinh doanh
class RoomModel {
  final String id;
  final String ownerId;
  final String propertyId;
  final String name; // VD: "Phòng 102", "Ki-ốt K01"
  final String type; // AppConstants.typeRoom hoặc AppConstants.typeKiosk
  final String status; // AppConstants.statusAvailable, OCCUPIED, MAINTENANCE
  final int baseRentPrice; // Giá thuê theo kỳ (VNĐ)
  final int depositAmount; // Tiền đặt cọc (VNĐ)
  final int billingCycleMonths; // Kỳ thu tiền: 1 (phòng trọ), 3/6/12 (ki-ốt)
  
  final String? currentTenantId;
  final String? currentTenantName;
  final String? currentTenantPhone;
  
  final int lastElectricNumber; // Chỉ số điện chốt gần nhất
  final int lastWaterNumber; // Chỉ số nước chốt gần nhất
  final DateTime updatedAt;

  RoomModel({
    required this.id,
    required this.ownerId,
    this.propertyId = 'main_property',
    required this.name,
    required this.type,
    required this.status,
    required this.baseRentPrice,
    required this.depositAmount,
    this.billingCycleMonths = 1,
    this.currentTenantId,
    this.currentTenantName,
    this.currentTenantPhone,
    this.lastElectricNumber = 0,
    this.lastWaterNumber = 0,
    required this.updatedAt,
  });

  bool get isKiosk => type == AppConstants.typeKiosk;
  bool get isOccupied => status == AppConstants.statusOccupied;
  bool get isAvailable => status == AppConstants.statusAvailable;
  bool get isMaintenance => status == AppConstants.statusMaintenance;

  RoomModel copyWith({
    String? id,
    String? ownerId,
    String? propertyId,
    String? name,
    String? type,
    String? status,
    int? baseRentPrice,
    int? depositAmount,
    int? billingCycleMonths,
    String? currentTenantId,
    String? currentTenantName,
    String? currentTenantPhone,
    int? lastElectricNumber,
    int? lastWaterNumber,
    DateTime? updatedAt,
    bool clearTenant = false,
  }) {
    return RoomModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      propertyId: propertyId ?? this.propertyId,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      baseRentPrice: baseRentPrice ?? this.baseRentPrice,
      depositAmount: depositAmount ?? this.depositAmount,
      billingCycleMonths: billingCycleMonths ?? this.billingCycleMonths,
      currentTenantId: clearTenant ? null : (currentTenantId ?? this.currentTenantId),
      currentTenantName: clearTenant ? null : (currentTenantName ?? this.currentTenantName),
      currentTenantPhone: clearTenant ? null : (currentTenantPhone ?? this.currentTenantPhone),
      lastElectricNumber: lastElectricNumber ?? this.lastElectricNumber,
      lastWaterNumber: lastWaterNumber ?? this.lastWaterNumber,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'propertyId': propertyId,
      'name': name,
      'type': type,
      'status': status,
      'baseRentPrice': baseRentPrice,
      'depositAmount': depositAmount,
      'billingCycleMonths': billingCycleMonths,
      'currentTenantId': currentTenantId,
      'currentTenantName': currentTenantName,
      'currentTenantPhone': currentTenantPhone,
      'lastElectricNumber': lastElectricNumber,
      'lastWaterNumber': lastWaterNumber,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory RoomModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RoomModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      propertyId: data['propertyId'] ?? 'main_property',
      name: data['name'] ?? '',
      type: data['type'] ?? AppConstants.typeRoom,
      status: data['status'] ?? AppConstants.statusAvailable,
      baseRentPrice: data['baseRentPrice'] ?? 0,
      depositAmount: data['depositAmount'] ?? 0,
      billingCycleMonths: data['billingCycleMonths'] ?? 1,
      currentTenantId: data['currentTenantId'],
      currentTenantName: data['currentTenantName'],
      currentTenantPhone: data['currentTenantPhone'],
      lastElectricNumber: data['lastElectricNumber'] ?? 0,
      lastWaterNumber: data['lastWaterNumber'] ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
