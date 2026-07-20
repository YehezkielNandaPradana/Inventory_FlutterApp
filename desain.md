# Design System — Aplikasi Inventory

**Tema:** Biru Muda & Putih · Clean · Modern
**Target:** Mobile app (Flutter) — sistem inventory

---

## 1. Filosofi Desain

Desain dibangun di atas kesan **ringan, rapi, dan terpercaya** — cocok untuk aplikasi yang dipakai setiap hari untuk mengelola stok barang. Biru muda memberi nuansa profesional tanpa terasa dingin/kaku, dipadukan dengan banyak ruang putih agar data (jumlah stok, kategori, status) tetap jadi fokus utama, bukan dekorasi.

Prinsip: *"data dulu, hiasan kemudian."* Setiap elemen visual (warna, badge, ikon) harus membantu pengguna langsung tahu kondisi stok dalam 1 detik pertama melihat layar.

---

## 2. Color Palette

| Token | Hex | Penggunaan |
|---|---|---|
| `primary-blue` | `#2D7DD2` | Tombol utama, ikon aktif, header, link |
| `sky-blue` | `#5FA8E0` | Aksen sekunder, hover/pressed state |
| `light-blue-bg` | `#EAF4FF` | Background section, card, input field |
| `pure-white` | `#FFFFFF` | Background dasar layar |
| `navy-text` | `#1B2B4B` | Judul, teks penting |
| `slate-text` | `#6B7A99` | Teks sekunder, deskripsi, placeholder |
| `success-green` | `#4CAF93` | Status "Stok Aman" |
| `warning-amber` | `#F2A93B` | Status "Stok Menipis" |
| `danger-red` | `#E5534B` | Status "Stok Habis" |

Aturan pakai:
- Background layar selalu putih bersih (`pure-white`), bukan biru — biru muda hanya untuk *section/card*, agar tidak terasa "penuh warna".
- `primary-blue` maksimal dipakai untuk 1 aksi utama per layar (tombol paling penting).
- Warna status (hijau/kuning/merah) **hanya** untuk indikator stok — jangan dipakai untuk elemen lain, supaya artinya tetap konsisten.

---

## 3. Tipografi

| Role | Font | Ukuran | Weight |
|---|---|---|---|
| Judul Halaman (H1) | Poppins | 24sp | SemiBold |
| Sub-judul (H2) | Poppins | 18sp | SemiBold |
| Judul Card (H3) | Poppins | 15sp | Medium |
| Body / Deskripsi | Inter | 14sp | Regular |
| Angka Stok (data) | Inter (tabular nums) | 16sp | SemiBold |
| Caption / label kecil | Inter | 12sp | Medium |

Poppins dipakai khusus untuk judul agar ada karakter "modern-rounded" yang ramah, sementara Inter menjaga keterbacaan body text & angka pada layar kecil.

---

## 4. Spacing & Grid

- Basis grid: **8px** → gunakan kelipatan 4/8/16/24/32 untuk semua margin & padding.
- Border radius:
  - Card: `16px`
  - Tombol: `12px` (atau full-round untuk tombol icon/FAB)
  - Input field: `10px`
  - Badge/pill status: full-round
- Shadow: soft shadow bertona biru — `rgba(45,125,210,0.08)`, blur besar, offset kecil (bukan shadow abu-abu default) supaya tetap terasa "biru muda" walau di atas putih.

---

## 5. Komponen Utama

**Card Item Inventory**
- Background putih, radius 16px, shadow biru lembut
- Ada **garis aksen vertikal** di sisi kiri card (3-4px) berwarna sesuai status stok (hijau/kuning/merah) — jadi user bisa scan kondisi stok tanpa baca teks
- Isi: nama barang (H3), kategori (caption abu), jumlah stok (angka besar SemiBold)

**Tombol**
- Primary: filled `primary-blue`, teks putih, radius 12px
- Secondary: outline `primary-blue`, teks biru, background transparan
- Ghost/text button: teks biru tanpa border, untuk aksi minor ("Lihat semua")

**Input Field**
- Background `light-blue-bg`, tanpa border saat idle
- Saat focus: border 1.5px `primary-blue`
- Label di atas field (bukan placeholder-only), agar jelas saat sudah terisi

**Badge Status Stok**
- Pill shape, background pucat dari warna status (misal hijau 10% opacity) + teks warna status solid
- Contoh: "Stok Aman" (hijau), "Menipis" (kuning), "Habis" (merah)

**Navigasi**
- Bottom navigation bar: background putih, ikon aktif biru + label, ikon nonaktif abu-abu
- App bar atas: background putih/biru muda tipis, judul kiri, ikon aksi kanan (search, notifikasi)

**Empty State**
- Ilustrasi outline sederhana bertema kotak/rak dengan garis biru muda
- Teks ajakan aksi, misal: "Belum ada barang. Tambah barang pertama kamu."

---

## 6. Ikonografi

- Gaya **outline/line icon**, stroke 2px (bukan filled solid), supaya terasa ringan & modern
- Warna: `primary-blue` untuk aktif, `slate-text`/abu untuk nonaktif
- Ikon yang relevan dengan tema inventory: kotak, rak, barcode/scan, panah masuk-keluar (stok masuk/keluar), grafik kecil

---

## 7. Elemen Signature — "Indikator Level Stok"

Elemen unik yang dipakai berulang di seluruh aplikasi (dashboard, list, detail barang): sebuah **capsule progress bar horizontal tipis** di bawah nama barang, track-nya biru muda pucat, isinya gradasi biru→hijau/kuning/merah sesuai persentase stok tersisa terhadap stok minimum. Ini jadi "identitas visual" khas aplikasi — sekali lihat bentuknya, user langsung tahu ini elemen stok.

```
Nama Barang           120 pcs
[███████████░░░░░░░░░]  ← capsule bar, warna sesuai level
Kategori: Alat Tulis
```

---

## 8. Contoh Wireframe (ASCII)

**Dashboard**
```
┌─────────────────────────────┐
│ Halo, Admin 👋      🔔      │
│                              │
│ ┌─────────┐ ┌─────────┐    │
│ │ Total    │ │ Stok     │    │
│ │ Barang   │ │ Menipis  │    │
│ │  248     │ │   6      │    │
│ └─────────┘ └─────────┘    │
│                              │
│ Barang Terbaru               │
│ ┌──────────────────────────┐ │
│ │▌Kertas A4        200 pcs │ │
│ │▌[████████████░░░]        │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │▌Spidol Hitam       4 pcs │ │
│ │▌[██░░░░░░░░░░░░░░]        │ │
│ └──────────────────────────┘ │
│                              │
│ [🏠]   [📦]   [➕]   [👤]    │
└─────────────────────────────┘
```

**Detail Barang**
```
┌─────────────────────────────┐
│ ← Detail Barang               │
│                              │
│  [ Foto Barang ]             │
│                              │
│  Kertas A4 80gsm              │
│  Kategori: Alat Tulis         │
│  Status: 🟢 Stok Aman         │
│                              │
│  Jumlah Stok       200 pcs   │
│  [██████████████░░░]         │
│                              │
│  [  Edit Barang  ] (outline) │
│  [ Kurangi Stok  ] (filled)  │
└─────────────────────────────┘
```

---

## 9. Do's & Don'ts

**Do:**
- Biarkan putih mendominasi, biru sebagai aksen
- Gunakan warna status hanya untuk info stok
- Konsisten pakai capsule progress bar di semua tempat yang menampilkan jumlah stok

**Don't:**
- Jangan pakai gradient biru mencolok di background besar — cukup di elemen kecil (progress bar/tombol)
- Jangan campur warna status dengan warna brand (misal jangan buat tombol utama warna hijau)
- Jangan gunakan lebih dari 1 font family untuk judul (konsisten Poppins)
