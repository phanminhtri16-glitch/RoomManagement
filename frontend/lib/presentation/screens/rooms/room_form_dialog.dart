import 'package:flutter/material.dart';
import 'package:room_management_app/core/constants/app_constants.dart';
import 'package:room_management_app/data/models/room_model.dart';
import 'package:room_management_app/data/repositories/room_repository.dart';

class RoomFormDialog extends StatefulWidget {
  final String ownerId;
  final RoomModel? initialRoom; // null nếu là tạo mới, có giá trị nếu là chỉnh sửa

  const RoomFormDialog({
    super.key,
    required this.ownerId,
    this.initialRoom,
  });

  @override
  State<RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<RoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late TextEditingController _nameController;
  late TextEditingController _rentPriceController;
  late TextEditingController _depositController;
  late TextEditingController _cycleController;
  late TextEditingController _electricController;
  late TextEditingController _waterController;
  bool _isLoading = false;

  bool get isEditing => widget.initialRoom != null;

  @override
  void initState() {
    super.initState();
    final room = widget.initialRoom;
    _type = room?.type ?? AppConstants.typeRoom;
    _nameController = TextEditingController(text: room?.name ?? '');
    _rentPriceController = TextEditingController(
      text: room != null ? room.baseRentPrice.toString() : '3000000',
    );
    _depositController = TextEditingController(
      text: room != null ? room.depositAmount.toString() : '3000000',
    );
    _cycleController = TextEditingController(
      text: room != null ? room.billingCycleMonths.toString() : '1',
    );
    _electricController = TextEditingController(
      text: room != null ? room.lastElectricNumber.toString() : '0',
    );
    _waterController = TextEditingController(
      text: room != null ? room.lastWaterNumber.toString() : '0',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rentPriceController.dispose();
    _depositController.dispose();
    _cycleController.dispose();
    _electricController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
                        isEditing ? 'Sửa Thông Tin Phòng' : 'Thêm Phòng / Ki-ốt Mới',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Lựa chọn loại: Phòng trọ hoặc Ki-ốt
                  const Text('Loại hình cho thuê', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: AppConstants.typeRoom,
                        icon: Icon(Icons.meeting_room_outlined),
                        label: Text('Phòng trọ'),
                      ),
                      ButtonSegment(
                        value: AppConstants.typeKiosk,
                        icon: Icon(Icons.storefront_outlined),
                        label: Text('Ki-ốt'),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _type = newSelection.first;
                        if (_type == AppConstants.typeKiosk && _cycleController.text == '1') {
                          _cycleController.text = '3'; // Gợi ý chu kỳ 3 tháng cho ki-ốt
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tên phòng / Ki-ốt
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: _type == AppConstants.typeRoom ? 'Tên / Số phòng *' : 'Tên Ki-ốt *',
                      hintText: _type == AppConstants.typeRoom ? 'VD: Phòng 101, Phòng 203' : 'VD: Ki-ốt K01, Gian hàng 1',
                      prefixIcon: Icon(_type == AppConstants.typeRoom ? Icons.door_front_door : Icons.store),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên phòng/ki-ốt';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Giá thuê định kỳ
                  TextFormField(
                    controller: _rentPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Giá thuê định kỳ (VNĐ) *',
                      hintText: 'VD: 3000000',
                      prefixIcon: Icon(Icons.payments_outlined),
                      suffixText: 'đ',
                    ),
                    validator: (value) {
                      if (value == null || int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) == null) {
                        return 'Vui lòng nhập giá thuê hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Chu kỳ thanh toán & Tiền cọc
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cycleController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Kỳ thu (tháng) *',
                            hintText: '1',
                            prefixIcon: Icon(Icons.calendar_month_outlined),
                          ),
                          validator: (value) {
                            final n = int.tryParse(value ?? '');
                            if (n == null || n < 1) return '>= 1 tháng';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _depositController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Tiền cọc (VNĐ)',
                            hintText: 'VD: 3000000',
                            prefixIcon: Icon(Icons.shield_outlined),
                            suffixText: 'đ',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Số điện & nước ban đầu (chỉ hiển thị rõ khi tạo mới)
                  if (!isEditing) ...[
                    const Text('Chỉ số ban đầu khi tạo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _electricController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Số điện đầu kỳ',
                              prefixIcon: Icon(Icons.electric_bolt, color: Colors.amber),
                              suffixText: 'kWh',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _waterController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Số nước đầu kỳ',
                              prefixIcon: Icon(Icons.water_drop, color: Colors.blue),
                              suffixText: 'm³',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Nút Lưu
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveRoom,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isEditing ? 'Cập Nhật' : 'Thêm Phòng'),
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

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final repo = RoomRepository();

    final rentPrice = int.parse(_rentPriceController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    final deposit = int.tryParse(_depositController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final cycle = int.tryParse(_cycleController.text) ?? 1;
    final electric = int.tryParse(_electricController.text) ?? 0;
    final water = int.tryParse(_waterController.text) ?? 0;

    try {
      if (isEditing) {
        final updated = widget.initialRoom!.copyWith(
          name: _nameController.text.trim(),
          type: _type,
          baseRentPrice: rentPrice,
          depositAmount: deposit,
          billingCycleMonths: cycle,
          updatedAt: DateTime.now(),
        );
        await repo.updateRoom(updated);
      } else {
        final newRoom = RoomModel(
          id: '',
          ownerId: widget.ownerId,
          name: _nameController.text.trim(),
          type: _type,
          status: AppConstants.statusAvailable,
          baseRentPrice: rentPrice,
          depositAmount: deposit,
          billingCycleMonths: cycle,
          lastElectricNumber: electric,
          lastWaterNumber: water,
          updatedAt: DateTime.now(),
        );
        await repo.createRoom(newRoom);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Đã cập nhật phòng thành công!' : 'Đã thêm phòng mới thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
