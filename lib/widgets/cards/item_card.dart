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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildImage(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barang.nama,
                  style: AppTextStyles.h2.copyWith(fontSize: 15),
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
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${barang.stok} pcs',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 15,
                  color: _statusColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                barang.status,
                style: AppTextStyles.caption.copyWith(
                  color: _statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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
