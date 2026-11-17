import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:room_management_app/data/models/tenant_model.dart';

class TenantRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  TenantRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference get _tenantsRef => _firestore.collection('tenants');
  CollectionReference get _roomsRef => _firestore.collection('rooms');

  /// Lắng nghe danh sách khách đang thuê (status == 'ACTIVE')
  Stream<List<TenantModel>> watchActiveTenants(String ownerId) {
    return _tenantsRef
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: 'ACTIVE')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TenantModel.fromSnapshot(doc)).toList();
    });
  }

  /// Lắng nghe danh sách khách đã trả phòng (status == 'CHECKED_OUT')
  Stream<List<TenantModel>> watchPastTenants(String ownerId) {
    return _tenantsRef
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: 'CHECKED_OUT')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TenantModel.fromSnapshot(doc)).toList();
    });
  }

  /// Lấy chi tiết một khách thuê
  Future<TenantModel?> getTenant(String tenantId) async {
    final doc = await _tenantsRef.doc(tenantId).get();
    if (!doc.exists) return null;
    return TenantModel.fromSnapshot(doc);
  }

  /// Cập nhật thông tin khách thuê
  Future<void> updateTenant(TenantModel tenant) async {
    final batch = _firestore.batch();
    final tenantRef = _tenantsRef.doc(tenant.id);
    batch.update(tenantRef, tenant.toMap());

    // Nếu khách đang thuê thì đồng bộ tên và số điện thoại sang Room
    if (tenant.isActive && tenant.roomId.isNotEmpty) {
      final roomRef = _roomsRef.doc(tenant.roomId);
      batch.update(roomRef, {
        'currentTenantName': tenant.fullName,
        'currentTenantPhone': tenant.phone,
        'depositAmount': tenant.depositPaid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Xóa hồ sơ khách thuê
  Future<void> deleteTenant(String tenantId) async {
    await _tenantsRef.doc(tenantId).delete();
  }

  /// Tải ảnh chụp CCCD hoặc hợp đồng lên Firebase Storage
  Future<String> uploadTenantDocument({
    required String ownerId,
    required String tenantId,
    required String documentType, // 'id_front', 'id_back', 'contract'
    required File imageFile,
  }) async {
    final ref = _storage
        .ref()
        .child('$ownerId/tenants/$tenantId/${documentType}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }
}
