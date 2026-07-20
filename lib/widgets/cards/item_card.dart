import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../models/barang_model.dart';

class ItemCard extends StatelessWidget {
  final Barang barang;
  final VoidCallback? onTap;

  const ItemCard({super.key, required this.barang, this.onTap});

  Color get _statusColor {
    switch (barang.status) {
      case 'Habis':
        return AppColors.dangerRed;
      case 'Menipis':
        return AppColors.warningAmber;
      default:
        return const Color.fromARGB(
          255,
          15,
          167,
          70,
        ); // hijau untuk status "Aman"
    }
  }

  IconData get _kategoriIcon {
    switch (barang.kategori) {
      case 'Alat Tulis':
        return Icons.edit_outlined;
      case 'Perlengkapan Kantor':
        return Icons.business_center_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImage(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barang.nama,
                    style: AppTextStyles.h3.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    barang.kategori,
                    style: AppTextStyles.bodySecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  _buildStockProgress(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${barang.stok} pcs',
                  style: AppTextStyles.stockNumber,
                ),
                const SizedBox(height: 4),
                _buildStatusBadge(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockProgress() {
    final percentage = barang.persentaseStok;
    final statusColor = _statusColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: AppColors.lightBlueBg,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = _statusColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        barang.status,
        style: AppTextStyles.caption.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildImage() {
    final gambar = barang.gambar;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: (gambar != null && gambar.isNotEmpty)
          ? Image.network(
              gambar,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _placeholder(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _placeholder(loading: true);
              },
            )
          : _placeholder(),
    );
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.lightBlueBg,
      alignment: Alignment.center,
      child: loading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue.withOpacity(0.6),
                ),
              ),
            )
          : Icon(_kategoriIcon, color: AppColors.primaryBlue, size: 26),
    );
  }
}
