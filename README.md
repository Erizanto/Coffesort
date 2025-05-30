# Sistem Penyortiran Biji Kopi Otomatis ☕📱⚙️

Aplikasi Flutter yang digunakan untuk menyortir biji kopi secara otomatis berdasarkan kualitas menggunakan deteksi gambar (Machine Learning) dan sistem IoT berbasis ESP32. Proyek ini menggabungkan pengolahan citra, mobile development, dan perangkat keras tertanam untuk menciptakan sistem kontrol kualitas biji kopi yang efisien.

---

## 📱 Tentang Proyek Ini

Aplikasi ini dirancang untuk:
- **Mendeteksi kualitas biji kopi** secara real-time menggunakan kamera dan model ML.
- **Menampilkan hasil klasifikasi ke pengguna**.
- **Mengirimkan hasil ke perangkat IoT (ESP32)** untuk menimbang dan menyortir biji kopi secara fisik.

---

## 🛠️ Teknologi yang Digunakan

| Komponen       | Teknologi                          | Deskripsi |
|----------------|------------------------------------|-----------|
| Antarmuka      | Flutter                            | Untuk membangun UI mobile lintas platform. |
| Machine Learning | TensorFlow Lite (TFLite)          | Model klasifikasi gambar yang berjalan di perangkat secara offline. |
| Backend Cloud  | Firebase Realtime Database         | Komunikasi dua arah antara aplikasi dan ESP32 secara real-time. |
| IoT Hardware   | ESP32 + Load Cell + HX711 + Servo  | Mikrokontroler dan aktuator untuk menimbang dan menyortir. |

---

## 📲 Fitur Aplikasi

### 🔹 Halaman Kamera
- Mengambil gambar biji kopi menggunakan kamera HP.
- Menjalankan klasifikasi gambar menggunakan model TFLite.
- Menampilkan label hasil dan confidence score.

### 🔹 Halaman Hasil
- Menampilkan label kualitas dan pratinjau gambar.
- Mengirim hasil deteksi ke Firebase Realtime Database.

### 🔹 Halaman Monitoring
- Menampilkan berat biji kopi yang ditimbang secara real-time.
- Menampilkan riwayat hasil penyortiran.

---

## 🔄 Arsitektur Sistem

```plaintext
[Aplikasi Flutter]
     ↔ Kamera + Model ML (TFLite)
     ↔ Firebase Realtime DB
         ↔ ESP32
              ↔ Load Cell + HX711
              ↔ Motor Servo

--
## 📊 Alur Sistem

```plaintext
Pengguna (Flutter App)
   ↓
Gambar biji kopi → Model TFLite → Label hasil
   ↓
Kirim hasil ke Firebase
   ↓
ESP32 membaca hasil
   ↓
Load Cell → Berat → Firebase → Aplikasi
   ↓
Servo Motor menyortir otomatis
