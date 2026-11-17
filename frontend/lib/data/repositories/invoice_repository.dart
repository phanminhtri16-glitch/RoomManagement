import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:room_management_app/data/models/invoice_model.dart';
import 'package:room_management_app/core/constants/app_constants.dart';

class InvoiceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  InvoiceRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference get _invoicesRef => _firestore.collection('invoices');

  /// Lắng nghe danh sách hóa đơn theo tháng (Realtime & Offline cache)
  Stream<List<InvoiceModel>> watchInvoices(String ownerId, String billingMonth) {
    return _invoicesRef
        .where('ownerId', isEqualTo: ownerId)
        .where('billingMonth', isEqualTo: billingMonth)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => InvoiceModel.fromSnapshot(doc)).toList();
    });
  }

  /// Tạo hoặc cập nhật hóa đơn
  Future<void> saveInvoice(InvoiceModel invoice) async {
    if (invoice.id.isEmpty) {
      await _invoicesRef.add(invoice.toMap());
    } else {
      await _invoicesRef.doc(invoice.id).set(invoice.toMap(), SetOptions(merge: true));
    }
  }

  /// Xác nhận đã thu tiền phòng 1 chạm (Mark as Paid)
  Future<void> markAsPaid(String invoiceId) async {
    await _invoicesRef.doc(invoiceId).update({
      'status': AppConstants.invoicePaid,
      'paidAt': FieldValue.serverTimestamp(),
    });
  }

  /// Tải ảnh chụp công tơ lên Firebase Storage (lưu giữ làm bằng chứng)
  Future<String> uploadMeterPhoto({
    required String ownerId,
    required String invoiceId,
    required String type, // 'electric' hoặc 'water'
    required File imageFile,
  }) async {
    final ref = _storage
        .ref()
        .child('$ownerId/invoices/$invoiceId/${type}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }
}
