# Pembukuan & Operasional Sari Purnama

Aplikasi mobile berbasis Flutter untuk mempermudah operasional dan pembukuan Sari Purnama. Saat ini fokus utama aplikasi adalah memfasilitasi pembuatan dan penyusunan foto nota menjadi dokumen Purchase Order (PO) PDF siap cetak dengan tata letak yang rapi dan presisi.

---

## Fitur Saat Ini

### Generator PO (Purchase Order)
- **Target Toko**:
  - Memilih toko yang ingin dibuatkan PO.
- **Pilihan Kertas**:
  - A4 (210 x 297 mm)
  - F4 / Folio (215 x 330 mm)
  - Margin tipis (2.5 mm) agar area nota maksimal dan terbaca jelas.
- **Pengaturan Tampilan Gambar**:
  - Preset skala: Selebar Kertas Penuh (Maksimal), Selebar Kertas (Proporsional), dan Standar (90% lebar kertas).
  - Pengurutan ulang urutan nota dan penghapusan item nota yang dipilih.
- **Ekspor & Cetak**:
  - Preview interaktif dokumen per halaman.
  - Cetak langsung (Direct Print) ke printer yang terhubung.
  - Simpan / download berkas PDF ke penyimpanan perangkat.

---

## Struktur Folder

Proyek di dalam folder `sp_mobile` menggunakan pendekatan Clean Architecture modular berbasis fitur:

```
pembukuan_sp/
├── lib/
│   ├── core/
│   │   ├── theme/            # Tema & palet warna
│   │   └── utils/            # Utilitas kalkulasi tata letak & paginasi
│   ├── features/
│   │   ├── home/             # Menu utama aplikasi
│   │   ├── po_generator/     # Fitur pembuatan PO (data, domain, presentation)
│   │   └── shell/            # Navigasi shell aplikasi
│   ├── app.dart
│   └── main.dart
```

---

## Cara Menjalankan

### Prasyarat
- Flutter SDK (versi 3.x)
- Android Studio / VS Code dengan ekstensi Flutter & Dart
- Perangkat fisik atau emulator

### Langkah Menjalankan
1. Masuk ke direktori Flutter:
   ```bash
   cd pembukuan_sp
   ```

2. Unduh dependensi:
   ```bash
   flutter pub get
   ```

3. Jalankan aplikasi:
   ```bash
   flutter run
   ```

---

## Dependensi Utama
- `pdf` & `printing`: Pembuatan dan pencetakan dokumen PDF.
- `image_picker`: Pengambilan foto nota dari kamera atau galeri.
- `intl`: Format tanggal dan mata uang.
- `path_provider`: Manajemen berkas di perangkat.