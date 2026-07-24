class Transaksi {
  final String id;
  final String barangId;
  final String barangNama;
  final String jenis;
  final int jumlah;
  final String tanggal;
  final String? keterangan;

  Transaksi({
    required this.id,
    required this.barangId,
    required this.barangNama,
    required this.jenis,
    required this.jumlah,
    required this.tanggal,
    this.keterangan,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    final barang = json['barang'] is Map<String, dynamic>
        ? json['barang'] as Map<String, dynamic>
        : null;

    return Transaksi(
      id: json['id']?.toString() ?? '',
      barangId: json['barang_id']?.toString() ?? '',
      barangNama: barang != null
          ? (barang['nama']?.toString() ?? '')
          : (json['barang_nama']?.toString() ?? ''),
      jenis: json['jenis']?.toString() ?? 'masuk',
      jumlah: json['jumlah'] is int
          ? json['jumlah']
          : int.tryParse(json['jumlah']?.toString() ?? '0') ?? 0,
      tanggal: json['tanggal']?.toString() ?? '',
      keterangan: json['keterangan']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barang_id': barangId,
      'barang_nama': barangNama,
      'jenis': jenis,
      'jumlah': jumlah,
      'tanggal': tanggal,
      'keterangan': keterangan,
    };
  }

  String get label {
    switch (jenis) {
      case 'masuk':
        return 'Barang Masuk';
      case 'rusak':
        return 'Kondisi Rusak';
      case 'keluar':
        return 'Barang Keluar';
      default:
        return jenis;
    }
  }
}
