import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:room_management_app/core/utils/currency_formatter.dart';
import 'package:room_management_app/data/models/tenant_model.dart';
import 'package:room_management_app/data/repositories/tenant_repository.dart';
import 'package:room_management_app/presentation/screens/tenants/tenant_form_dialog.dart';

class TenantDetailDialog extends StatefulWidget {
  final TenantModel tenant;
  final String ownerId;
  final Function(TenantModel)? onTenantUpdated;

  const TenantDetailDialog({
    super.key,
    required this.tenant,
    required this.ownerId,
    this.onTenantUpdated,
  });

  @override
  State<TenantDetailDialog> createState() => _TenantDetailDialogState();
}

class _TenantDetailDialogState extends State<TenantDetailDialog> {
  late TenantModel _tenant;
  final _tenantRepo = TenantRepository();

  @override
  void initState() {
    super.initState();
    _tenant = widget.tenant;
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _tenant.isActive;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tenant.fullName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green.withOpacity(0.12) : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isActive ? 'Đang thuê phòng: ${_tenant.roomName}' : 'Đã trả phòng (${_tenant.roomName})',
                              style: TextStyle(
                                color: isActive ? Colors.green.shade800 : Colors.grey.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Thông tin liên hệ & Pháp lý
                _buildInfoSection('Thông Tin Liên Hệ & Pháp Lý', [
                  _buildDetailRow(Icons.phone_outlined, 'Số điện thoại', _tenant.phone),
                  _buildDetailRow(Icons.badge_outlined, 'Số Căn cước công dân', _tenant.idCardNumber),
                  _buildDetailRow(Icons.calendar_today_outlined, 'Ngày vào ở', DateFormat('dd/MM/yyyy').format(_tenant.startDate)),
                  if (_tenant.checkoutDate != null)
                    _buildDetailRow(Icons.event_busy_outlined, 'Ngày trả phòng', DateFormat('dd/MM/yyyy').format(_tenant.checkoutDate!)),
                  _buildDetailRow(Icons.payments_outlined, 'Tiền cọc đã nộp', CurrencyFormatter.format(_tenant.depositPaid)),
                ]),
                const SizedBox(height: 16),

                // Thông tin lưu trú
                _buildInfoSection('Thông Tin Lưu Trú & Phương Tiện', [
                  _buildDetailRow(Icons.people_outline, 'Số người ở cùng', '${_tenant.numberOfResidents} người'),
                  _buildDetailRow(
                    Icons.two_wheeler_outlined,
                    'Biển số xe',
                    _tenant.vehiclePlates.isNotEmpty ? _tenant.vehiclePlates.join(', ') : 'Không đăng ký xe',
                  ),
                  if (_tenant.note.isNotEmpty)
                    _buildDetailRow(Icons.notes_outlined, 'Ghi chú', _tenant.note),
                ]),
                const SizedBox(height: 16),

                // Ảnh chụp CCCD / Hợp đồng
                if (_tenant.idCardFrontUrl != null || _tenant.idCardBackUrl != null || _tenant.contractPhotoUrl != null) ...[
                  const Text('Hình Ảnh Giấy Tờ Lưu Trữ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (_tenant.idCardFrontUrl != null)
                        Expanded(child: _buildDocPreview('CCCD Trước', _tenant.idCardFrontUrl!)),
                      if (_tenant.idCardBackUrl != null) ...[
                        const SizedBox(width: 8),
                        Expanded(child: _buildDocPreview('CCCD Sau', _tenant.idCardBackUrl!)),
                      ],
                      if (_tenant.contractPhotoUrl != null) ...[
                        const SizedBox(width: 8),
                        Expanded(child: _buildDocPreview('Hợp đồng', _tenant.contractPhotoUrl!)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                        onPressed: _openEditDialog,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Sửa Thông Tin'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          backgroundColor: const Color(0xFF0F766E),
                        ),
                        onPressed: () {
                          // Gọi điện nhanh
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gọi đến ${_tenant.phone}')),
                          );
                        },
                        icon: const Icon(Icons.call, size: 18),
                        label: const Text('Gọi Điện'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F766E))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDocPreview(String label, String url) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: url,
            height: 80,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.grey.shade200, height: 80),
            errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, height: 80, child: const Icon(Icons.broken_image)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  void _openEditDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => TenantFormDialog(
        ownerId: widget.ownerId,
        initialTenant: _tenant,
      ),
    );
    if (result == true) {
      final updated = await _tenantRepo.getTenant(_tenant.id);
      if (updated != null && mounted) {
        setState(() => _tenant = updated);
        widget.onTenantUpdated?.call(updated);
      }
    }
  }
}
