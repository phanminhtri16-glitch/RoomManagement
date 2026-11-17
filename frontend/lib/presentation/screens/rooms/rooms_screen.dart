import 'package:flutter/material.dart';
import 'package:room_management_app/core/constants/app_constants.dart';
import 'package:room_management_app/core/utils/currency_formatter.dart';
import 'package:room_management_app/data/models/room_model.dart';
import 'package:room_management_app/data/repositories/room_repository.dart';
import 'package:room_management_app/presentation/screens/rooms/room_form_dialog.dart';
import 'package:room_management_app/presentation/screens/rooms/room_detail_screen.dart';

class RoomsScreen extends StatefulWidget {
  final String ownerId;

  const RoomsScreen({super.key, this.ownerId = 'default_owner'});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _roomRepo = RoomRepository();
  bool _filterAvailableOnly = false;

  // Dữ liệu mẫu dùng khi chạy thử nghiệm chưa kết nối Firebase
  final List<RoomModel> _mockRooms = [
    RoomModel(
      id: 'mock_1',
      ownerId: 'default_owner',
      name: 'Ki-ốt K01 (Mặt tiền)',
      type: AppConstants.typeKiosk,
      status: AppConstants.statusOccupied,
      baseRentPrice: 6500000,
      depositAmount: 13000000,
      billingCycleMonths: 3,
      currentTenantName: 'Nguyễn Văn An (Tạp hóa An Phát)',
      currentTenantPhone: '0912345678',
      lastElectricNumber: 1420,
      lastWaterNumber: 85,
      updatedAt: DateTime.now(),
    ),
    RoomModel(
      id: 'mock_2',
      ownerId: 'default_owner',
      name: 'Phòng 101 (Tầng 1)',
      type: AppConstants.typeRoom,
      status: AppConstants.statusOccupied,
      baseRentPrice: 3200000,
      depositAmount: 3200000,
      billingCycleMonths: 1,
      currentTenantName: 'Trần Thị Bích',
      currentTenantPhone: '0987654321',
      lastElectricNumber: 840,
      lastWaterNumber: 42,
      updatedAt: DateTime.now(),
    ),
    RoomModel(
      id: 'mock_3',
      ownerId: 'default_owner',
      name: 'Phòng 102 (Tầng 1)',
      type: AppConstants.typeRoom,
      status: AppConstants.statusAvailable,
      baseRentPrice: 3000000,
      depositAmount: 3000000,
      billingCycleMonths: 1,
      lastElectricNumber: 520,
      lastWaterNumber: 30,
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phòng Trọ & Ki-ốt', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0F766E),
          indicatorColor: const Color(0xFF0F766E),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Ki-ốt'),
            Tab(text: 'Phòng trọ'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _filterAvailableOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _filterAvailableOnly ? const Color(0xFF0F766E) : null,
            ),
            tooltip: _filterAvailableOnly ? 'Đang lọc: Chỉ phòng trống' : 'Lọc chỉ phòng trống',
            onPressed: () {
              setState(() {
                _filterAvailableOnly = !_filterAvailableOnly;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<RoomModel>>(
        stream: _roomRepo.watchRooms(widget.ownerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var rooms = snapshot.data ?? [];

          // Nếu có lỗi kết nối Firebase hoặc chưa chạy flutterfire configure, dùng mock data để preview UI
          if (snapshot.hasError || (snapshot.data == null && rooms.isEmpty)) {
            rooms = _mockRooms;
          }

          if (rooms.isEmpty) {
            return _buildEmptyState();
          }

          if (_filterAvailableOnly) {
            rooms = rooms.where((r) => r.isAvailable).toList();
          }

          final kiosks = rooms.where((r) => r.isKiosk).toList();
          final residentialRooms = rooms.where((r) => !r.isKiosk).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRoomList(rooms),
              _buildRoomList(kiosks),
              _buildRoomList(residentialRooms),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddRoomDialog,
        backgroundColor: const Color(0xFF0F766E),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm phòng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work_outlined, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Chưa có phòng trọ hay ki-ốt nào',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bấm nút bên dưới để tạo phòng trọ sinh hoạt hoặc mặt bằng ki-ốt đầu tiên của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openAddRoomDialog,
              icon: const Icon(Icons.add),
              label: const Text('Thêm Phòng / Ki-ốt Ngay'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomList(List<RoomModel> rooms) {
    if (rooms.isEmpty) {
      return Center(
        child: Text(
          _filterAvailableOnly ? 'Không có phòng nào đang trống.' : 'Chưa có phòng trong mục này.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final room = rooms[index];
        final isOccupied = room.isOccupied;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RoomDetailScreen(
                    room: room,
                    ownerId: widget.ownerId,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            room.isKiosk ? Icons.storefront : Icons.meeting_room,
                            color: const Color(0xFF0F766E),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            room.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      _buildStatusChip(room.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Giá: ${CurrencyFormatter.format(room.baseRentPrice)}${room.billingCycleMonths > 1 ? " / ${room.billingCycleMonths} tháng" : " / tháng"}',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F766E)),
                      ),
                      Text(
                        'Điện: ${room.lastElectricNumber} | Nước: ${room.lastWaterNumber}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  if (isOccupied && room.currentTenantName != null) ...[
                    const Divider(height: 18),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            room.currentTenantName!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (room.currentTenantPhone != null) ...[
                          const Icon(Icons.phone_outlined, size: 15, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(room.currentTenantPhone!, style: const TextStyle(fontSize: 13)),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case AppConstants.statusOccupied:
        bg = Colors.green.withOpacity(0.12);
        fg = Colors.green.shade800;
        label = 'Đang thuê';
        break;
      case AppConstants.statusMaintenance:
        bg = Colors.orange.withOpacity(0.15);
        fg = Colors.orange.shade800;
        label = 'Sửa chữa';
        break;
      default:
        bg = Colors.amber.withOpacity(0.15);
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
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _openAddRoomDialog() {
    showDialog(
      context: context,
      builder: (_) => RoomFormDialog(ownerId: widget.ownerId),
    );
  }
}
