# Modul 02 — Catatan Bukti

| Hal | Isi |
|---|---|
| Nama | Syuhada Rantisi |
| NIM | `122140092` |
| Kelompok | `k01` |
| Kasus | Klinik Sehat Lampung |
| Peninjau PR `m02` (NIM) | `122450066` |

## Dugaan pre-lab

| Dugaan | Isi |
|---|---|
| Waktu siap server goreng dibanding server dari AMI (detik) | Hampir sama setelah `Creation complete`, sekitar 0–2 detik, karena cloud-init tidak memasang paket. |
| Alasan dugaan | AMI panggang sudah berisi aplikasi dan unit systemd; goreng masih menulis file dan mengaktifkan service. |

## Langkah dan bukti

| Potret | Langkah | Keadaan | Waktu (WIB) | Hasil penting |
|---:|---|---|---|---|
| 1 | C.4.5 | api 2.1.0 dari AMI 2.1.0 | 17:57:35 | Latihan lulus; semua cek runtime lulus, immutable belum karena baru satu versi. |
| 6 | D.4 | api 2.0.0, ID baru | 18:43:24 | `ami-09adba744334290af`; API sehat; immutable lulus setelah dibandingkan dengan versi 2.1.0. |
| 8 | D.4 | api 2.1.0, ID baru | 19:00:35 | `ami-093bea1bfbc74a25a`; `/versi` 2.1.0; API sehat. |
| 10 | Latihan 2.1 | api 2.1.0 + server goreng | 19:02:06 | API dan goreng hidup; `/versi` goreng 2.1.0 dengan host berbeda; Latihan lulus. |
| 11 | E.2.2 | bersih setelah `tofu destroy` | 19:04:56 | Potret kosong; `latihan_lulus: true`, `tugas_lulus: true`. |
| 12 | Rilis kasus 2.2.0 | API `t3.small` dari AMI rilis | 2026-11-11 16:40 WIB | Potret aktif; semua cek selain `bersih_akhir` lulus. |
| 13 | Pekerjaan Wajib 6 | bersih setelah destroy rilis | 2026-11-11 16:42 WIB | `tugas_lulus: true`, potret terakhir kosong. |

## Catatan Bagian A

| Hal | Isi |
|---|---|
| AMI publik terbaru | `ami-03988d3be5ed1bfdb`, `al2023-ami-2023.12.20261109.0-kernel-6.12-x86_64` |
| `pemilik` (OwnerId) | `137112412989` |
| `virtualisasi`, `ena`, `root` | `hvm`, `true`, `ebs` |
| Hypervisor, vCPU, memori `t2.micro` | Xen, 1 vCPU, 1024 MiB |
| Hypervisor, vCPU, memori `t3.micro` | Nitro, 2 vCPU, 1024 MiB |
| Hypervisor, vCPU, memori `t3.small` | Nitro, 2 vCPU, 2048 MiB |
| Ukuran user data | `5558` karakter untuk versi 2.1.0 |

Pembangun cukup memakai `t3.micro` karena hanya menjalankan cloud-init dan membuat AMI,
bukan melayani trafik produksi.

## Catatan Bagian B

| Hal | Isi |
|---|---|
| `aws_instance.pembangun` Creation complete | 16 detik; contoh ID 2.1.0 `i-03f5e42f1986922e1` |
| `time_sleep.tunggu_cloud_init` Creation complete | 2m0s |
| `aws_ami_from_instance.api` Creation complete | 3m13s untuk AMI 2.0.0; sekitar 3m04s untuk AMI 2.1.0 awal |
| Waktu panggang | sekitar 5m29s–5m30s setelah pembangun selesai |
| ID dan nama AMI | `ami-09adba744334290af` / `koma-122140092-m02-api-2.0.0`; `ami-093bea1bfbc74a25a` / `koma-122140092-m02-api-2.1.0` |
| `OwnerId` AMI | Akun sendiri; AMI dibuat oleh `aws_ami_from_instance` dari akun praktikan |
| Jeda cloud-init | `120s` sesuai `time_sleep`; tidak ada instalasi paket |

Jeda 120 detik cukup secara operasional karena AMI berhasil dibuat dan API hasil panggangan
menjawab `/health` 200; jeda ini tidak mengukur service melalui IP publik pembangun.

## Catatan Bagian C

| Hal | Isi |
|---|---|
| `url_api` 2.2.0 | `http://15.134.134.186` |
| ID instance api 2.2.0 | `i-021946d3e2f889583` |
| `aws_instance.api` Creation complete | 16 detik |
| Waktu siap | 0,6 detik setelah `Creation complete` |
| Jawaban `/versi` | `{"versi":"2.2.0","peran":"api","host":"ip-172-31-3-241.ap-southeast-2.compute.internal"}` |
| Aturan masuk | TCP/80 dari `182.253.63.6/32` |
| Isi `keluar` | `IpPermissionsEgress: []` |

## Catatan Bagian D

| Hal | Sebelum (2.0.0) | Sesudah (2.1.0) |
|---|---|---|
| ID instance api | `i-02f9b930883ce2a81` | `i-0bd3e3e6180f189f1` |
| IP publik api | `3.25.83.255` | `54.206.1.192` |
| ID AMI | `ami-09adba744334290af` | `ami-093bea1bfbc74a25a` |

Rantai replacement: perubahan `versi` mengubah cloud-init dan memaksa `pembangun`,
`time_sleep`, AMI, lalu instance api dibuat ulang. Plan menunjukkan resource lama dihancurkan
dan resource versi baru dibuat; `user_data_replace_on_change = true` menjadi salah satu
atribut pemicu pada pembangun.

API lama berhenti ketika instance lama dihancurkan sebelum instance baru siap. Karena itu
peralihan ini menimbulkan jeda layanan; alamat publik juga berubah dan harus diumumkan atau
diletakkan di belakang mekanisme endpoint stabil pada sistem produksi.

## Catatan Bagian E

| Hal | Isi |
|---|---|
| Ringkasan destroy | Resource M02 (goreng, api, AMI, pembangun, SG, ingress, dan sleep) dihancurkan; output akhir kosong. |
| `describe-images --owners self` | Tidak ada AMI M02 yang tersisa setelah destroy. |
| `koma sisa` | Tidak ada instance tanpa `managed-by`; instance dan AMI M02 sudah dibersihkan. |
| `bersih_akhir` dan `Tugas lulus` | `true` pada potret 11. |

## Catatan Tugas

| Hal | Isi |
|---|---|
| Versi rilis kasus | `2.2.0`, lebih tinggi dari latihan `2.1.0`; dipilih untuk rilis immutable KSL. |
| Ukuran server api | `t3.small`, karena C3 mencapai 420 req/detik dan E4–E5 menetapkan SLA 99,95% serta p95 <500 ms. |
| ID AMI publik | `ami-03988d3be5ed1bfdb` |
| Waktu panggang | sekitar 5m28s setelah pembangun selesai (`16s + 120s + 3m12s`) |
| Waktu siap | 0,6 detik setelah `Creation complete` |
| ID instance api rilis | `i-021946d3e2f889583` |
| Jawaban `/versi` | Versi `2.2.0`, host `ip-172-31-3-241.ap-southeast-2.compute.internal` |
| Tautan PR | Belum dibuat; perlu dibuka setelah commit dan push |
| NIM/tanggal persetujuan | `122450066`; tanggal persetujuan belum ada |
