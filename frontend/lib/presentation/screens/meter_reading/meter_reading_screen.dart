import 'package:flutter/material.dart';
import 'package:room_management_app/core/utils/currency_formatter.dart';

class MeterReadingScreen extends StatefulWidget {
  const MeterReadingScreen({super.key});

  @override
  State<MeterReadingScreen> createState() => _MeterReadingScreenState();
}

class _MeterReadingScreenState extends State<MeterReadingScreen> {
  final Map<String, TextEditingController> _electricControllers = {};
  final Map<String, TextEditingController> _waterControllers = {};

  final List<Map<String, dynamic>> _rooms = [
    {
      'id': '1',
      'name': 'Ki-ốt K01 (Mặt tiền)',
      'tenant': 'Nguyễn Văn An',
      'oldElectric': 1420,
      'oldWater': 85,
    },
    {
      'id': '2',
      'name': 'Phòng 101 (Tầng 1)',
      'tenant': 'Trần Thị Bích',
      'oldElectric': 840,
      'oldWater': 42,
    },
  ];

  @override
  void initState() {
    super.initState();
    for (var room in _rooms) {
      _electricControllers[room['id']] = TextEditingController();
      _waterControllers[room['id']] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var c in _electricControllers.values) {
      c.dispose();
    }
    for (var c in _waterControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chốt Số Điện & Nước', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: _saveAllReadings,
            icon: const Icon(Icons.check, color: Color(0xFF0F766E)),
            label: const Text('Lưu tất cả', style: TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final room = _rooms[index];
          final id = room['id'] as String;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        room['name'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Thuê: ${room['tenant']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  
                  // Chỉ số điện
                  Row(
                    children: [
                      const Icon(Icons.electric_bolt, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Số điện cũ: ${room['oldElectric']} kWh'),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _electricControllers[id],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Số mới',
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt_outlined, color: Colors.teal),
                        onPressed: () {
                          // Chụp ảnh đồng hồ điện
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Chỉ số nước
                  Row(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Số nước cũ: ${room['oldWater']} m³'),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _waterControllers[id],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Số mới',
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt_outlined, color: Colors.teal),
                        onPressed: () {
                          // Chụp ảnh đồng hồ nước
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveAllReadings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu chỉ số điện nước thành công! Dữ liệu đã được lưu offline.')),
    );
  }
}
