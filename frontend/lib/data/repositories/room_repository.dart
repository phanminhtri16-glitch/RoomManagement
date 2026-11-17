import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:room_management_app/data/models/room_model.dart';
import 'package:room_management_app/data/models/tenant_model.dart';
import 'package:room_management_app/core/constants/app_constants.dart';

class RoomRepository {
  final FirebaseFirestore _firestore;

  RoomRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _roomsRef => _firestore.collection('rooms');
  CollectionReference get _tenantsRef => _firestore.collection('tenants');

  /// Lắng nghe danh sách phòng thời gian thực (tự động cache offline)
  Stream<List<RoomModel>> watchRooms(String ownerId) {
    return _roomsRef
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RoomModel.fromSnapshot(doc)).toList();
    });
  }

  /// Lấy thông tin chi tiết một phòng
  Future<RoomModel?> getRoom(String roomId) async {
    final doc = await _roomsRef.doc(roomId).get();
    if (!doc.exists) return null;
    return RoomModel.fromSnapshot(doc);
  }

  /// Thêm phòng mới hoặc ki-ốt mới
  Future<String> createRoom(RoomModel room) async {
    final docRef = await _roomsRef.add(room.toMap());
    return docRef.id;
  }

  /// Cập nhật thông tin phòng / ki-ốt
  Future<void> updateRoom(RoomModel room) async {
    await _roomsRef.doc(room.id).update(room.toMap());
  }

  /// Xóa phòng (chỉ cho phép khi phòng trống để tránh mất dữ liệu liên quan)
  Future<void> deleteRoom(String roomId) async {
    final doc = await _roomsRef.doc(roomId).get();
    if (!doc.exists) return;
    final room = RoomModel.fromSnapshot(doc);
    if (room.isOccupied) {
      throw Exception('Không thể xóa phòng đang có khách thuê. Vui lòng trả phòng trước!');
    }
    await _roomsRef.doc(roomId).delete();
  }

  /// Quy trình Nhận khách thuê (Check-in):
  /// Batch ghi cùng lúc: Tạo hồ sơ khách thuê + Chuyển phòng sang trạng thái Đang thuê
  Future<void> checkInRoom({
    required String roomId,
    required TenantModel tenant,
  }) async {
    final batch = _firestore.batch();

    // 1. Tạo document mới cho Tenant
    final newTenantDoc = _tenantsRef.doc();
    final tenantToSave = tenant.copyWith(
      id: newTenantDoc.id,
      roomId: roomId,
      status: 'ACTIVE',
    );
    batch.set(newTenantDoc, tenantToSave.toMap());

    // 2. Cập nhật Room sang trạng thái OCCUPIED kèm thông tin khách
    final roomRef = _roomsRef.doc(roomId);
    batch.update(roomRef, {
      'status': AppConstants.statusOccupied,
      'currentTenantId': newTenantDoc.id,
      'currentTenantName': tenant.fullName,
      'currentTenantPhone': tenant.phone,
      'depositAmount': tenant.depositPaid,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Quy trình Trả phòng (Check-out):
  /// Batch cập nhật: Đổi khách sang CHECKED_OUT + Trả phòng về AVAILABLE
  Future<void> checkOutRoom({
    required String roomId,
    required String tenantId,
  }) async {
    final batch = _firestore.batch();

    // 1. Cập nhật Tenant sang trạng thái CHECKED_OUT
    final tenantRef = _tenantsRef.doc(tenantId);
    batch.update(tenantRef, {
      'status': 'CHECKED_OUT',
      'checkoutDate': FieldValue.serverTimestamp(),
    });

    // 2. Cập nhật Room về AVAILABLE và xóa thông tin khách hiện tại
    final roomRef = _roomsRef.doc(roomId);
    batch.update(roomRef, {
      'status': AppConstants.statusAvailable,
      'currentTenantId': null,
      'currentTenantName': null,
      'currentTenantPhone': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Cập nhật chỉ số điện nước sau khi chốt sổ
  Future<void> updateMeterNumbers({
    required String roomId,
    required int newElectric,
    required int newWater,
  }) async {
    await _roomsRef.doc(roomId).update({
      'lastElectricNumber': newElectric,
      'lastWaterNumber': newWater,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cập nhật trạng thái phòng (AVAILABLE, OCCUPIED, MAINTENANCE)
  Future<void> updateRoomStatus(String roomId, String status) async {
    await _roomsRef.doc(roomId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
