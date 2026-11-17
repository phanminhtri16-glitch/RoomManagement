import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_management_app/data/models/tenant_model.dart';
import 'package:room_management_app/data/repositories/room_repository.dart';
import 'package:room_management_app/data/repositories/tenant_repository.dart';

class TenantFormDialog extends StatefulWidget {
  final String ownerId;
  final String roomId;
  final String roomName;
  final int suggestedDeposit;
  final TenantModel? initialTenant; // Nếu khác null là chỉnh sửa hồ sơ

  const TenantFormDialog({
    super.key,
    required this.ownerId,
    this.roomId = '',
    this.roomName = '',
    this.suggestedDeposit = 0,
    this.initialTenant,
  });

  @override
  State<TenantFormDialog> createState() => _TenantFormDialogState();
}

class _TenantFormDialogState extends State<TenantFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _idCardController;
  late TextEditingController _depositController;
  late TextEditingController _residentsController;
  late TextEditingController _vehiclesController;
  late TextEditingController _noteController;

  late DateTime _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _showAdvanced = false;

  File? _idCardFrontFile;
  File? _idCardBackFile;
  File? _contractFile;

  bool get isEditing => widget.initialTenant != null;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTenant;
    _fullNameController = TextEditingController(text: t?.fullName ?? '');
    _phoneController = TextEditingController(text: t?.phone ?? '');
    _idCardController = TextEditingController(text: t?.idCardNumber ?? '');
    _depositController = TextEditingController(
      text: t != null ? t.depositPaid.toString() : (widget.suggestedDeposit > 0 ? widget.suggestedDeposit.toString() : '3000000'),
    );
    _residentsController = TextEditingController(text: t != null ? t.numberOfResidents.toString() : '1');
    _vehiclesController = TextEditingController(text: t?.vehiclePlates.join(', ') ?? '');
    _noteController = TextEditingController(text: t?.note ?? '');
    _startDate = t?.startDate ?? DateTime.now();
    _endDate = t?.endDate;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _idCardController.dispose();
    _depositController.dispose();
    _residentsController.dispose();
    _vehiclesController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Sửa Hồ Sơ Khách Thuê' : 'Nhận Khách Thuê Phòng',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  if (widget.roomName.isNotEmpty && !isEditing) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Phòng bàn giao: ${widget.roomName}',
                        style: TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Họ và tên
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên khách thuê *',
                      hintText: 'VD: Nguyễn Văn An',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
                  ),
                  const SizedBox(height: 12),

                  // Số điện thoại & CCCD
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Số điện thoại *',
                            hintText: 'VD: 0912345678',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập SĐT' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _idCardController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Số CCCD *',
                            hintText: '12 chữ số',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập CCCD' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tiền cọc & Ngày vào ở
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _depositController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Tiền cọc thực nộp (đ) *',
                            hintText: 'VD: 3000000',
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                          validator: (v) => (v == null || int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) == null)
                              ? 'Nhập số tiền cọc'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _pickStartDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Ngày vào ở *',
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                            ),
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(_startDate),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nút gập/mở thông tin bổ sung
                  TextButton.icon(
                    onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
                    icon: Icon(_showAdvanced ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                    label: Text(_showAdvanced ? 'Thu gọn thông tin bổ sung' : 'Thêm thông tin xe, số người, ảnh CCCD'),
                  ),

                  if (_showAdvanced) ...[
                    const Divider(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _residentsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Số người ở cùng',
                              hintText: '1',
                              prefixIcon: Icon(Icons.people_outline),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _vehiclesController,
                            decoration: const InputDecoration(
                              labelText: 'Biển số xe',
                              hintText: 'VD: 59A-12345, 29B-6789',
                              prefixIcon: Icon(Icons.two_wheeler_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú thêm',
                        hintText: 'VD: Khách làm ca đêm, có nuôi 1 thú cưng nhỏ...',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Chụp ảnh CCCD / Hợp đồng
                    const Text('Giấy tờ tùy thân & Hợp đồng (Tùy chọn)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDocUploadButton(
                            title: 'Mặt trước CCCD',
                            file: _idCardFrontFile,
                            onPick: () => _pickImage((f) => setState(() => _idCardFrontFile = f)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDocUploadButton(
                            title: 'Mặt sau CCCD',
                            file: _idCardBackFile,
                            onPick: () => _pickImage((f) => setState(() => _idCardBackFile = f)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDocUploadButton(
                            title: 'Hợp đồng thuê',
                            file: _contractFile,
                            onPick: () => _pickImage((f) => setState(() => _contractFile = f)),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveTenant,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isEditing ? 'Cập Nhật Hồ Sơ' : 'Xác Nhận Nhận Phòng'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocUploadButton({
    required String title,
    required File? file,
    required VoidCallback onPick,
  }) {
    final hasFile = file != null;
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: hasFile ? Colors.teal.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: hasFile ? Colors.teal : Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(hasFile ? Icons.check_circle : Icons.camera_alt_outlined, size: 20, color: hasFile ? Colors.teal : Colors.grey.shade700),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: hasFile ? Colors.teal.shade900 : Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }

  void _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  void _pickImage(Function(File) onSelected) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked != null) {
      onSelected(File(picked.path));
    }
  }

  Future<void> _saveTenant() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final deposit = int.parse(_depositController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    final residents = int.tryParse(_residentsController.text) ?? 1;
    final vehicles = _vehiclesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    try {
      if (isEditing) {
        final updated = widget.initialTenant!.copyWith(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          idCardNumber: _idCardController.text.trim(),
          depositPaid: deposit,
          startDate: _startDate,
          endDate: _endDate,
          numberOfResidents: residents,
          vehiclePlates: vehicles,
          note: _noteController.text.trim(),
        );
        final tenantRepo = TenantRepository();
        await tenantRepo.updateTenant(updated);

        // Upload ảnh nếu có chọn mới
        if (_idCardFrontFile != null) {
          final url = await tenantRepo.uploadTenantDocument(
            ownerId: widget.ownerId,
            tenantId: updated.id,
            documentType: 'id_front',
            imageFile: _idCardFrontFile!,
          );
          await tenantRepo.updateTenant(updated.copyWith(idCardFrontUrl: url));
        }
        if (_idCardBackFile != null) {
          final url = await tenantRepo.uploadTenantDocument(
            ownerId: widget.ownerId,
            tenantId: updated.id,
            documentType: 'id_back',
            imageFile: _idCardBackFile!,
          );
          await tenantRepo.updateTenant(updated.copyWith(idCardBackUrl: url));
        }
      } else {
        final newTenant = TenantModel(
          id: '',
          ownerId: widget.ownerId,
          roomId: widget.roomId,
          roomName: widget.roomName,
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          idCardNumber: _idCardController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          depositPaid: deposit,
          numberOfResidents: residents,
          vehiclePlates: vehicles,
          note: _noteController.text.trim(),
          status: 'ACTIVE',
        );

        final roomRepo = RoomRepository();
        await roomRepo.checkInRoom(roomId: widget.roomId, tenant: newTenant);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Đã cập nhật hồ sơ khách thuê!' : 'Đã nhận phòng thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
