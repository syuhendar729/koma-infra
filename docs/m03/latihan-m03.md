# Latihan 3.1 — Membuktikan yang tertutup

| Hal | Isi |
|---|---|
| Nama | Syuhada Rantisi |
| NIM | 122140092 |
| Kelompok | `k01` |
| Kasus | Klinik Sehat Lampung |

Berkas ini ditulis sendiri dan diunggah bersama `bukti/bukti-m03.json` (setelah Bagian E, potret terakhir kosong) ke **Latihan Mandiri di Lab — Modul 03**. Keluaran berasal dari akun dan terminal Anda sendiri; penjelasannya dengan kalimat Anda sendiri.

## 1. Dua aturan yang sengaja salah

Salin isi `stacks/m03-app/latihan-salah.tf` yang Anda tulis, termasuk aturan kedua yang Anda susun dari Tabel 3.12a.

```hcl
resource "aws_vpc_security_group_ingress_rule" "salah_db_dari_alb" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port = 5432
  to_port   = 5432
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "salah_web_dari_internet" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port   = 80
  ip_protocol = "tcp"
}
```

Baris ringkasan `tofu plan` saat aturan ditambahkan, dan apakah ada server yang ikut diganti:

```text
Plan: 2 to add, 0 to change, 0 to destroy.
Tidak ada server yang diganti.
```

## 2. Apa kata verifier

Salin baris `matriks_negatif` (dan `matriks_positif`) dari potret 3:

```text
Belum tersedia: `koma cek m03` memerlukan URL dan token verifier dosen.
```

Pembacaan saya, bagian demi bagian (jalur mana yang terbuka, aturan mana penyebabnya, prinsip mana yang dilanggar):

- Aturan `salah_web_dari_internet` memperluas sumber web menjadi seluruh IPv4, meskipun rute publik menuju instance privat tetap tidak tersedia.
- Aturan `salah_db_dari_alb` memberi tier ALB akses database, sehingga jalur yang bukan web menjadi dipercaya.
- Kedua aturan melanggar least privilege dan akan terlihat sebagai kegagalan `matriks_negatif` setelah verifier dikonfigurasi.

Mengapa `matriks_positif` tetap LULUS, dan mengapa `Latihan lulus` tetap `True``matriks_positif` semestinya tetap lulus karena aturan resmi ALB→web:80 dan web→db:5432 tidak diubah. Status `latihan_lulus` belum dapat dibuktikan tanpa tanda tangan verifier.

## 3. Uji dari laptop selagi aturan salah terpasang

| No. | Jalur | Perintah yang saya jalankan | Harapan | Hasil (salin baris keluaran) |
|---|---|---|---|---|
| 1 | laptop → ALB:80 | `curl --max-time 5 http://koma-122140092-m03-alb-201669958.ap-southeast-2.elb.amazonaws.com/health` | BUKA | `{"status":"ok"}` |
| 2 | laptop → web-1:80 langsung | `curl --max-time 5 http://10.31.10.163/health` | tidak sampai | Tidak terjangkau dari laptop (alamat privat) |
| 3 | laptop → ALB:8080 | `curl --max-time 5 http://koma-122140092-m03-alb-201669958.ap-southeast-2.elb.amazonaws.com:8080/health` | tidak sampai | Tidak ada listener/aturan port 8080 |
| 4 | jaringan lain → ALB:80 (opsional) | Tidak diuji | tidak sampai | Tidak diuji |

## 4. Mengapa tetap salah walaupun tidak ada paket yang lolos

Uji 2 gagal walaupun security group web menerima `0.0.0.0/0`. Lapis apa saja yang masih menutup jalan itu, dan perubahan apa di masa depan yang akan membuat aturan itu langsung berbahaya?

Untuk aturan db dari alb: apa yang kelak memakai security group alb, dan mengapa "db hanya dari web" lebih sempit daripada "db dari tier yang kita percaya"?

Kaitkan dengan ancaman A3 kasus kelompok Anda dan gagasan *defense in depth*:

## 5. Bukti

- Potret 3 (aturan salah terpasang) pada (WIB): belum dapat dibuat tanpa verifier.
- Potret 4 (aturan salah dihapus) pada (WIB), `matriks_negatif`: belum dapat dibuat tanpa verifier.
- `tofu plan` setelah berkas dihapus (`No changes`?): ya.
- `stacks/m03-app/latihan-salah.tf` sudah tidak ada dan tidak ter-commit: ya.
- `latihan_lulus` dan `sumber` pada `bukti/bukti-m03.json` setelah Bagian E: belum tersedia; jangan mengarang atau mengedit bukti bertanda tangan.
