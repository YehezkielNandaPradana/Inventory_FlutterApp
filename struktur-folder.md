# Struktur Folder — Aplikasi Inventory (Flutter)

Struktur ini pakai pendekatan **feature-based** (dikelompokkan per fitur: barang, kategori, stok, dashboard) supaya gampang dinavigasi meski masih belajar Flutter — tiap fitur folder-nya jelas, tidak semua file numpuk jadi satu.

```
inventory_app/
│
├── android/                      # konfigurasi native Android (auto-generate)
├── ios/                          # konfigurasi native iOS (auto-generate)
│
├── assets/
│   ├── images/                   # ilustrasi, logo, empty-state image
│   ├── icons/                    # ikon custom (outline style, sesuai desain.md)
│   └── fonts/
│       ├── Poppins/               # untuk judul (H1, H2, H3)
│       └── Inter/                 # untuk body text & angka
│
├── lib/
│   ├── main.dart                 # entry point aplikasi
│   ├── app.dart                  # setup MaterialApp, routing utama
│   │
│   ├── config/
│   │   ├── theme.dart             # ThemeData: primary-blue, light-blue-bg, dst
│   │   ├── colors.dart            # konstanta warna (dari desain.md)
│   │   ├── text_styles.dart       # konstanta typography (Poppins/Inter)
│   │   ├── routes.dart            # daftar named routes
│   │   └── constants.dart         # string, ukuran spacing (8/16/24), dll
│   │
│   ├── models/
│   │   ├── barang_model.dart      # struktur data barang (nama, stok, kategori, dst)
│   │   ├── kategori_model.dart
│   │   └── transaksi_model.dart   # riwayat stok masuk / keluar
│   │
│   ├── services/
│   │   ├── database_service.dart  # koneksi SQLite/local DB (init, CRUD dasar)
│   │   ├── barang_service.dart    # query khusus barang
│   │   ├── kategori_service.dart
│   │   └── transaksi_service.dart
│   │
│   ├── providers/                 # state management (Provider/Riverpod)
│   │   ├── barang_provider.dart
│   │   ├── kategori_provider.dart
│   │   └── dashboard_provider.dart # total barang, stok menipis, dll
│   │
│   ├── screens/
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── barang/
│   │   │   ├── barang_list_screen.dart
│   │   │   ├── barang_detail_screen.dart
│   │   │   └── barang_form_screen.dart   # tambah/edit barang
│   │   ├── kategori/
│   │   │   └── kategori_screen.dart
│   │   └── stok/
│   │       └── stok_masuk_keluar_screen.dart
│   │
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── custom_button.dart        # primary/secondary/ghost button
│   │   │   ├── custom_input.dart         # input field (light-blue-bg style)
│   │   │   ├── status_badge.dart         # badge Aman/Menipis/Habis
│   │   │   └── stock_progress_bar.dart   # elemen signature: capsule progress bar
│   │   ├── cards/
│   │   │   └── item_card.dart            # card barang di list/dashboard
│   │   └── navigation/
│   │       └── bottom_nav_bar.dart
│   │
│   └── utils/
│       ├── validators.dart        # validasi form (stok tidak boleh negatif, dll)
│       ├── formatters.dart        # format angka/tanggal
│       └── extensions.dart
│
├── test/
│   ├── unit/                      # test untuk service & model
│   └── widget/                    # test untuk widget/screen
│
├── pubspec.yaml                   # dependencies & konfigurasi asset/font
└── README.md
```

## Penjelasan singkat tiap folder

| Folder | Isi & Tujuan |
|---|---|
| `config/` | Semua "aturan tampilan" global — warna, font, spacing dari `desain.md` dipusatkan di sini supaya tidak hardcode warna di banyak file |
| `models/` | Bentuk data murni (class), tidak ada logic tampilan atau database di sini |
| `services/` | Tempat baca/tulis data (database, nanti bisa diganti API tanpa ubah UI) |
| `providers/` | Penghubung antara `services` dan `screens` — nge-manage state (misal daftar barang yang lagi ditampilkan) |
| `screens/` | Satu file = satu halaman penuh |
| `widgets/` | Komponen kecil yang dipakai berulang di banyak screen (card, tombol, badge) |
| `utils/` | Fungsi bantu kecil yang tidak berhubungan dengan tampilan atau data langsung |

## Urutan belajar yang disarankan

1. `models/` dulu — tentukan data barang itu bentuknya seperti apa
2. `config/theme.dart` & `colors.dart` — biar dari awal semua screen udah konsisten warnanya
3. `widgets/common/` — bikin komponen dasar (tombol, input, badge, progress bar)
4. `screens/barang/` — halaman pertama yang dibangun (list & detail barang)
5. `services/` & `providers/` — baru dihubungkan ke database setelah UI-nya jadi

Urutan ini supaya kamu bisa lihat hasil visual duluan (sesuai tema `desain.md`) sebelum masuk ke bagian data/database yang biasanya lebih rumit buat pemula.
