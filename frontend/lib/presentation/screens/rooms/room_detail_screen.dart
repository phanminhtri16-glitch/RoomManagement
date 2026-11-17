import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:room_management_app/core/constants/app_constants.dart';
import 'package:room_management_app/core/utils/currency_formatter.dart';
import 'package:room_management_app/data/models/room_model.dart';
import 'package:room_management_app/data/models/tenant_model.dart';
import 'package:room_management_app/data/repositories/room_repository.dart';
import 'package:room_management_app/data/repositories/tenant_repository.dart';
import 'package:room_management_app/presentation/screens/rooms/room_form_dialog.dart';
import 'package:room_management_app/presentation/screens/tenants/tenant_form_dialog.dart';
import 'package:room_management_app/presentation/screens/tenants/tenant_detail_dialog.dart';

class RoomDetailScreen extends StatefulWidget {
  final RoomModel room;
  final String ownerId;

  const RoomDetailScreen({
    super.key,
    required this.room,
    required this.ownerId,
  });

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late RoomModel _currentRoom;
  TenantModel? _currentTenant;
  bool _isLoadingTenant = false;
  final _roomRepo = RoomRepository();
  final _tenantRepo = TenantRepository();

  @override
  void initState() {
    super.initState();
    _currentRoom = widget.room;
    _fetchTenantDetails();
  }

  Future<void> _fetchTenantDetails() async {
    if (_currentRoom.currentTenantId != null && _currentRoom.currentTenantId!.isNotEmpty) {
      setState(() => _isLoadingTenant = true);
      try {
        final tenant = await _tenantRepo.getTenant(_currentRoom.currentTenantId!);
        if (mounted) setState(() => _currentTenant = tenant);
      } finally {
        if (mounted) setState(() => _isLoadingTenant = false);
      }
    } else {
      setState(() => _currentTenant = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOccupied = _currentRoom.isOccupied;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentRoom.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Sửa thông tin phòng',
            onPressed: _openEditRoomDialog,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              if (!_currentRoom.isOccupied)
                PopupMenuItem(
                  value: _currentRoom.isMaintenance ? 'SET_AVAILABLE' : 'SET_MAINTENANCE',
                  child: Row(
                    children: [
                      Icon(_currentRoom.isMaintenance ? Icons.check_circle_outline : Icons.build_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(_currentRoom.isMaintenance ? 'Chuyển sang Còn trống' : 'Báo Đang sửa chữa'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'DELETE_ROOM',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text('Xóa phòng này', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _buildHeaderCard(),
            const SizedBox(height: 16),

            // Thông số & Đơn giá
            _buildSpecsCard(),
            const SizedBox(height: 16),

            // Card Khách thuê (hoặc CTA nhận khách)
            if (isOccupied) ...[
              _buildTenantCard(),
            ] else ...[
              _buildAvailableCtaCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      color: const Color(0xFF0F766E),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _currentRoom.isKiosk ? Icons.storefront : Icons.meeting_room,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentRoom.name,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentRoom.isKiosk ? 'Mặt bằng Ki-ốt kinh doanh' : 'Phòng trọ sinh hoạt',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(_currentRoom.status),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông Tin Giá & Chỉ Số', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            _buildInfoRow(
              'Giá thuê định kỳ',
              '${CurrencyFormatter.format(_currentRoom.baseRentPrice)} / ${_currentRoom.billingCycleMonths} tháng',
              valueColor: const Color(0xFF0F766E),
              isBold: true,
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Tiền đặt cọc', CurrencyFormatter.format(_currentRoom.depositAmount)),
            const SizedBox(height: 10),
            _buildInfoRow('Chu kỳ thu tiền', '${_currentRoom.billingCycleMonths} tháng / lần'),
            const SizedBox(height: 10),
            _buildInfoRow(
              'Chỉ số chốt gần nhất',
              'Điện: ${_currentRoom.lastElectricNumber} kWh | Nước: ${_currentRoom.lastWaterNumber} m³',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Khách Thuê Hiện Tại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _openTenantDetail,
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Xem hồ sơ'),
                ),
              ],
            ),
            const Divider(height: 16),
            if (_isLoadingTenant)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
            else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF0F766E).withOpacity(0.12),
                  child: const Icon(Icons.person, color: Color(0xFF0F766E)),
                ),
                title: Text(
                  _currentRoom.currentTenantName ?? 'Chưa rõ họ tên',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text('SĐT: ${_currentRoom.currentTenantPhone ?? "Chưa có"}'),
              ),
              if (_currentTenant != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow('Số CCCD', _currentTenant!.idCardNumber.isNotEmpty ? _currentTenant!.idCardNumber : 'Chưa cập nhật'),
                const SizedBox(height: 6),
                _buildInfoRow('Ngày vào thuê', DateFormat('dd/MM/yyyy').format(_currentTenant!.startDate)),
                const SizedBox(height: 6),
                _buildInfoRow('Tiền cọc thực nộp', CurrencyFormatter.format(_currentTenant!.depositPaid)),
                if (_currentTenant!.vehiclePlates.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _buildInfoRow('Biển số xe', _currentTenant!.vehiclePlates.join(', ')),
                ],
              ],
              const SizedBox(height: 16),
              // Nút Trả phòng (Check-out)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                    minimumSize: const Size.fromHeight(44),
                  ),
                  onPressed: _confirmCheckout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Trả Phòng (Check-out)'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableCtaCard() {
    return Card(
      color: Colors.teal.shade50.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.teal.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.person_add_alt_1_outlined, size: 48, color: Colors.teal.shade700),
            const SizedBox(height: 12),
            const Text(
              'Phòng này hiện đang trống',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Bấm vào nút bên dưới để nhập hồ sơ khách thuê mới và bàn giao phòng.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _openCheckInDialog,
              icon: const Icon(Icons.add),
              label: const Text('Nhận Khách Thuê Mới'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case AppConstants.statusOccupied:
        bg = Colors.greenAccent.shade100;
        fg = Colors.green.shade900;
        label = 'Đang thuê';
        break;
      case AppConstants.statusMaintenance:
        bg = Colors.orangeAccent.shade100;
        fg = Colors.orange.shade900;
        label = 'Sửa chữa';
        break;
      default:
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        label = 'Còn trống';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _openEditRoomDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => RoomFormDialog(
        ownerId: widget.ownerId,
        initialRoom: _currentRoom,
      ),
    );
    if (result == true) {
      final updated = await _roomRepo.getRoom(_currentRoom.id);
      if (updated != null && mounted) {
        setState(() => _currentRoom = updated);
      }
    }
  }

  void _openCheckInDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => TenantFormDialog(
        ownerId: widget.ownerId,
        roomId: _currentRoom.id,
        roomName: _currentRoom.name,
        suggestedDeposit: _currentRoom.depositAmount,
      ),
    );
    if (result == true) {
      final updated = await _roomRepo.getRoom(_currentRoom.id);
      if (updated != null && mounted) {
        setState(() => _currentRoom = updated);
        _fetchTenantDetails();
      }
    }
  }

  void _openTenantDetail() {
    if (_currentTenant != null) {
      showDialog(
        context: context,
        builder: (_) => TenantDetailDialog(
          tenant: _currentTenant!,
          ownerId: widget.ownerId,
          onTenantUpdated: (updatedTenant) {
            setState(() => _currentTenant = updatedTenant);
          },
        ),
      );
    }
  }

  void _confirmCheckout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận Trả phòng?'),
        content: Text(
          'Khách "${_currentRoom.currentTenantName}" sẽ được chuyển sang trạng thái "Đã trả phòng" để lưu vết hồ sơ. Phòng "${_currentRoom.name}" sẽ trở lại trạng thái "Còn trống".',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xác nhận trả phòng'),
          ),
        ],
      ),
    );

    if (confirm == true && _currentRoom.currentTenantId != null) {
      try {
        await _roomRepo.checkOutRoom(
          roomId: _currentRoom.id,
          tenantId: _currentRoom.currentTenantId!,
        );
        final updated = await _roomRepo.getRoom(_currentRoom.id);
        if (updated != null && mounted) {
          setState(() {
            _currentRoom = updated;
            _currentTenant = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã thực hiện trả phòng thành công!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  void _handleMenuAction(String action) async {
    if (action == 'SET_AVAILABLE' || action == 'SET_MAINTENANCE') {
      final newStatus = action == 'SET_AVAILABLE' ? AppConstants.statusAvailable : AppConstants.statusMaintenance;
      await _roomRepo.updateRoomStatus(_currentRoom.id, newStatus);
      final updated = await _roomRepo.getRoom(_currentRoom.id);
      if (updated != null && mounted) setState(() => _currentRoom = updated);
    } else if (action == 'DELETE_ROOM') {
      if (_currentRoom.isOccupied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể xóa phòng đang có khách thuê!'), backgroundColor: Colors.orange),
        );
        return;
      }
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xóa phòng này?'),
          content: Text('Bạn có chắc chắn muốn xóa "${_currentRoom.name}" không? Thao tác này không thể hoàn tác.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Xóa vĩnh viễn'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await _roomRepo.deleteRoom(_currentRoom.id);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa phòng thành công!')),
          );
        }
      }
    }
  }
}
