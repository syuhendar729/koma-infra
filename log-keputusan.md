# Log Keputusan

Satu baris per keputusan desain. ID berbentuk `K-<modul>-<nomor>`, misalnya `K-01-001`. Alasan
merujuk kode bukti kasus kelompok (P1–P6, E1–E8, …). Keputusan kelompok yang sama boleh muncul di
repo setiap anggota; kolom Pengusul diisi NIM anggota yang mengusulkan.

| ID | Tanggal | Keputusan | Alasan (rujuk kode bukti kasus) | Pengusul (NIM) |
|---|---|---|---|---|
| K-01-001 | 2026-11-10 | Memetakan `portal-pasien`, `api-rme`, dan `worker-lab` ke katalog layanan `for_each`. | E1 memisahkan portal, API RME, serta worker/antrean; label peran membuat inventaris server uji yang ditemukan setelah P5 dapat diaudit. | 122140092 |
| K-01-002 | 2026-11-10 | Memakai `t3.small` untuk `api-rme` dan `t3.micro` untuk portal serta worker. | E4 menetapkan SLA API RME 99,95% dan E5 menargetkan p95 di bawah 500 ms; komponen pendukung cukup memakai preset kecil. | 122140092 |
| K-01-003 | 2026-11-10 | Menggunakan `for_each`, blok `moved`, dan tanpa IP publik. | E1 menunjukkan komponen yang perlu dibedakan oleh kunci; E4 membuat penggantian server berisiko; P5 menunjukkan dampak gangguan dan server yang dibuat tangan. | 122140092 |
| K-02-001 | 2026-11-11 | Merilis versi `2.2.0` dengan proses bake AMI dan serve immutable. | E4 menetapkan SLA API RME 99,95%; E5 menetapkan p95 < 500 ms; hasil M02 sebelumnya menunjukkan waktu siap API sekitar 0,5 detik dari AMI sendiri. | 122140092 |
| K-02-002 | 2026-11-11 | Memakai `t3.small` untuk server API rilis; pembangun tetap `t3.micro`. | C3 memproyeksikan 90–420 req/detik dan 24 server API; E4–E5 membutuhkan kapasitas lebih besar daripada pembangun yang hanya membuat AMI. | 122140092 |
| K-02-003 | 2026-11-11 | Memakai bake untuk API RME dan fry hanya sebagai pembanding sementara. | E1 memuat API RME dan worker yang menangani alur klinis; E6 menyebut tim platform junior; E2 mencakup 70 klinik dan 2 laboratorium sehingga konsistensi rilis lebih penting daripada konfigurasi manual. | 122140092 |
