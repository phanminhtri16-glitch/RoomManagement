import 'package:cloud_firestore/cloud_firestore.dart';

/// Đại diện cho một dãy trọ, tòa nhà hoặc khu ki-ốt
class PropertyModel {
  final String id;
  final String ownerId;
  final String name; // Tên khu (VD: "Dãy trọ Tân Bình", "Khu Ki-ốt Chợ Chiều")
  final String address;
  final int electricPrice; // Đơn giá điện (đ/kWh)
  final int waterPrice; // Đơn giá nước (đ/m3 hoặc đ/người)
  final int garbageFee; // Phí rác cố định
  final int internetFee; // Phí wifi cố định
  final DateTime createdAt;

  PropertyModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.electricPrice,
    required this.waterPrice,
    required this.garbageFee,
    required this.internetFee,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'electricPrice': electricPrice,
      'waterPrice': waterPrice,
      'garbageFee': garbageFee,
      'internetFee': internetFee,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PropertyModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PropertyModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      electricPrice: data['electricPrice'] ?? 3500,
      waterPrice: data['waterPrice'] ?? 20000,
      garbageFee: data['garbageFee'] ?? 30000,
      internetFee: data['internetFee'] ?? 50000,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
