# Modul 01 — Catatan Bukti

| Hal | Isi |
|---|---|
| Nama | Syuhada Rantisi |
| NIM | `122140092` |
| Kelompok | `k01` |
| Kasus | Klinik Sehat Lampung |

## Log langkah

| Langkah | Waktu (WIB) | Perintah | Hasil singkat |
|---|---|---|---|
| B.1 Anggaran | 2026-11-10 17:00 | `tofu apply m00.tfplan` | Budget `koma-122140092-anggaran`, batas USD 50, berhasil dibuat. |
| Tugas: plan katalog | 2026-11-10 17:22 | `tofu plan -out=m01.tfplan` | Katalog tiga layanan; perubahan create. |
| Tugas: apply katalog | 2026-11-10 17:22 | `tofu apply m01.tfplan` | Tiga instance katalog berjalan tanpa IP publik. |
| Tugas: potret aktif | 2026-11-10 17:22 | `koma cek m01` | Potret 10; `tugas_lulus` belum final karena stack masih aktif. |
| C.1 Plan kedua | 2026-11-10 17:24 | `tofu plan -detailed-exitcode` | Exit code `0`; tidak ada perubahan. |
| Tugas: destroy akhir | 2026-11-10 17:25 | `tofu destroy` | Tiga instance dan network interface katalog dihancurkan. |
| Tugas: potret bersih | 2026-11-10 17:26 | `koma cek m01` | Potret 12 kosong; `tugas_lulus: true`. |
| Tugas: sisa | 2026-11-10 17:26 | `koma sisa` | Tidak ada instance tanpa tag `managed-by`; resource terminated lama masih tampil karena retensi AWS. |

## Catatan Bagian A

- Region: `ap-southeast-2` (Sydney), sesuai konfigurasi akun praktikum.
- Instance manual yang teridentifikasi dan sudah dihentikan:
  - `coba-konsol`: `i-0264e7940fff8f3da`
  - `coba-cli`: `i-0418f5cfcc1bc1cac`
- ID `coba-cli` kedua, waktu klik konsol, dan durasi CLI tidak tersedia pada catatan lokal yang tersisa; tidak diada-adakan.
- Semua instance manual Bagian A sudah diminta terminate dan tidak lagi berstatus `running`.

## Catatan Bagian D

- Plan kedua (C.1): exit code = `0`.
- Potret aktif katalog akhir (potret 10):
  - `portal-pasien`: `i-019ef2e67053d029d`
  - `api-rme`: `i-0298c99ed6869a2d1`
  - `worker-lab`: `i-0e58f9a253c27c9cc`
- Pasangan ID untuk bukti reproducible:
  - Potret 3: `portal-pasien` `i-0d8f34b8d85663f57`, `api-rme` `i-0e69e76a641f6dc6f`
  - Potret 10: `portal-pasien` `i-019ef2e67053d029d`, `api-rme` `i-0298c99ed6869a2d1`
- Potret yang meluluskan `reproducible`: potret 3 dan potret 10.

### Model layanan

| Komponen | IaaS / PaaS / SaaS / bukan model layanan | Alasan |
|---|---|---|
| Instance EC2 | IaaS | Saya memilih image, tipe, jaringan, metadata, dan lifecycle instance. |
| AWS Budgets | PaaS | AWS menyediakan layanan terkelola untuk budget dan notifikasi biaya tanpa mengelola servernya. |
| Repo GitHub | SaaS | Repo dipakai melalui layanan aplikasi GitHub; server GitHub tidak saya kelola. |
| Workbench (panel Tugas) | SaaS | Pengumpulan dan penilaian dilakukan melalui aplikasi layanan yang sudah disediakan. |
| `koma cek` | Bukan model layanan cloud | Ini alat CLI lokal untuk memeriksa bukti terhadap akun dan repo. |

### Karakteristik cloud yang dialami

| Karakteristik ([Surianarayanan & Chelliah] hlm. 40–45) | Dialami / dibatasi / tidak | Bukti |
|---|---|---|
| On-demand provisioning | Dialami | Instance dibuat dengan OpenTofu dan API EC2, lalu dihancurkan dengan `tofu destroy`. |
| Self-service | Dialami | Seluruh apply, plan, cek, dan destroy dijalankan dari akun sendiri. |
| Resource pooling, multi-tenancy | Dialami | Instance memakai resource AWS bersama; detail tenant lain tidak terlihat. |
| Rapid elasticity | Dialami dengan batas Free plan | Tiga layanan dapat dibuat dan dihentikan cepat, tetapi tipe dan kuota dibatasi. |
| Measured service | Dialami | Resource memiliki ID, tipe, status, tag, dan budget USD 50. |
| Broad network access | Dialami dengan pembatasan jaringan | Console, CLI, API, dan OpenTofu dapat digunakan; instance katalog sengaja tanpa IP publik. |

## Potret Tugas

- Katalog kasus (`default` di `variables.tf`): `portal-pasien`/web/`t3.micro`, `api-rme`/api/`t3.small`, `worker-lab`/worker/`t3.micro`.
- Potret aktif katalog kasus: potret 10, 2026-11-10 17:22 WIB.
- Potret bersih terakhir: potret 12, 2026-11-10 17:26 WIB.
- `tugas_lulus`: `true`; `latihan_lulus`: `true`.
