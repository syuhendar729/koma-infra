# Log Keputusan

Satu baris per keputusan desain. ID berbentuk `K-<modul>-<nomor>`, misalnya `K-01-001`. Alasan
merujuk kode bukti kasus kelompok (P1–P6, E1–E8, …). Keputusan kelompok yang sama boleh muncul di
repo setiap anggota; kolom Pengusul diisi NIM anggota yang mengusulkan.

| ID | Tanggal | Keputusan | Alasan (rujuk kode bukti kasus) | Pengusul (NIM) |
|---|---|---|---|---|
| K-01-001 | 2026-11-10 | Memetakan `portal-pasien`, `api-rme`, dan `worker-lab` ke katalog layanan `for_each`. | E1 memisahkan portal, API RME, serta worker/antrean; label peran membuat inventaris server uji yang ditemukan setelah P5 dapat diaudit. | 122140092 |
| K-01-002 | 2026-11-10 | Memakai `t3.small` untuk `api-rme` dan `t3.micro` untuk portal serta worker. | E4 menetapkan SLA API RME 99,95% dan E5 menargetkan p95 di bawah 500 ms; komponen pendukung cukup memakai preset kecil. | 122140092 |
| K-01-003 | 2026-11-10 | Menggunakan `for_each`, blok `moved`, dan tanpa IP publik. | E1 menunjukkan komponen yang perlu dibedakan oleh kunci; E4 membuat penggantian server berisiko; P5 menunjukkan dampak gangguan dan server yang dibuat tangan. | 122140092 |
