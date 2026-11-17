import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:room_management_app/core/utils/currency_formatter.dart';
import 'package:room_management_app/data/models/tenant_model.dart';
import 'package:room_management_app/data/repositories/tenant_repository.dart';
import 'package:room_management_app/presentation/screens/tenants/tenant_detail_dialog.dart';

class TenantsScreen extends StatefulWidget {
  final String ownerId;

  const TenantsScreen({super.key, this.ownerId = 'default_owner'});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tenantRepo = TenantRepository();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<TenantModel> _mockActiveTenants = [
    TenantModel(
      id: 'mock_t1',
      ownerId: 'default_owner',
      roomId: 'mock_1',
      roomName: 'Ki-ốt K01',
      fullName: 'Nguyễn Văn An',
      phone: '0912345678',
      idCardNumber: '001200123456',
      startDate: DateTime(2026, 1, 15),
      depositPaid: 13000000,
      numberOfResidents: 2,
      vehiclePlates: ['59A-12345'],
      status: 'ACTIVE',
    ),
    TenantModel(
      id: 'mock_t2',
      ownerId: 'default_owner',
      roomId: 'mock_2',
      roomName: 'Phòng 101',
      fullName: 'Trần Thị Bích',
      phone: '0987654321',
      idCardNumber: '001201987654',
      startDate: DateTime(2026, 3, 1),
      depositPaid: 3200000,
      numberOfResidents: 1,
      vehiclePlates: ['29B-98765'],
      status: 'ACTIVE',
    ),
  ];

  final List<TenantModel> _mockPastTenants = [
    TenantModel(
      id: 'mock_t3',
      ownerId: 'default_owner',
      roomId: 'mock_3',
      roomName: 'Phòng 102',
      fullName: 'Lê Hoàng Nam',
      phone: '0901234567',
      idCardNumber: '001200555666',
      startDate: DateTime(2025, 6, 1),
      checkoutDate: DateTime(2026, 10, 31),
      depositPaid: 3000000,
      numberOfResidents: 1,
      status: 'CHECKED_OUT',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Khách Thuê', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0F766E),
          indicatorColor: const Color(0xFF0F766E),
          tabs: const [
            Tab(text: 'Đang thuê'),
            Tab(text: 'Đã trả phòng'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, SĐT, CCCD, phòng...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStreamList(_tenantRepo.watchActiveTenants(widget.ownerId), isActiveList: true),
                _buildStreamList(_tenantRepo.watchPastTenants(widget.ownerId), isActiveList: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamList(Stream<List<TenantModel>> stream, {required bool isActiveList}) {
    return StreamBuilder<List<TenantModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var list = snapshot.data ?? [];

        // Fallback sang mock data nếu chưa kết nối Firebase
        if (snapshot.hasError || (snapshot.data == null && list.isEmpty)) {
          list = isActiveList ? _mockActiveTenants : _mockPastTenants;
        }

        // Lọc theo từ khóa tìm kiếm
        if (_searchQuery.isNotEmpty) {
          list = list.where((t) {
            return t.fullName.toLowerCase().contains(_searchQuery) ||
                t.phone.toLowerCase().contains(_searchQuery) ||
                t.idCardNumber.toLowerCase().contains(_searchQuery) ||
                t.roomName.toLowerCase().contains(_searchQuery);
          }).toList();
        }

        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActiveList ? Icons.people_outline : Icons.history_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isActiveList
                        ? (_searchQuery.isNotEmpty ? 'Không tìm thấy khách thuê phù hợp.' : 'Chưa có khách nào đang thuê phòng.')
                        : 'Chưa có lịch sử khách trả phòng.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final tenant = list[index];

            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => TenantDetailDialog(
                      tenant: tenant,
                      ownerId: widget.ownerId,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isActiveList ? const Color(0xFF0F766E).withOpacity(0.12) : Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          color: isActiveList ? const Color(0xFF0F766E) : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    tenant.fullName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tenant.roomName.isNotEmpty ? tenant.roomName : 'Phòng trọ',
                                    style: TextStyle(color: Colors.teal.shade900, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SĐT: ${tenant.phone} • CCCD: ${tenant.idCardNumber}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isActiveList
                                      ? 'Thuê từ: ${DateFormat('dd/MM/yyyy').format(tenant.startDate)}'
                                      : 'Đã trả: ${tenant.checkoutDate != null ? DateFormat('dd/MM/yyyy').format(tenant.checkoutDate!) : "Chưa rõ"}',
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                ),
                                Text(
                                  'Cọc: ${CurrencyFormatter.format(tenant.depositPaid)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF0F766E)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
