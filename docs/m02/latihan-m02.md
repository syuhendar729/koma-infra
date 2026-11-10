# Latihan 2.1 — Goreng atau panggang

| Hal | Isi |
|---|---|
| Nama | Syuhada Rantisi |
| NIM | `122140092` |
| Kelompok | `k01` |
| Kasus | Klinik Sehat Lampung |

## 1. Kode server goreng

Kode yang ditambahkan di akhir `main.tf`:

```hcl
resource "aws_instance" "goreng" {
  count                       = var.bandingkan_goreng ? 1 : 0
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.bawaan.id
  associate_public_ip_address = true
  vpc_security_group_ids     = [aws_security_group.api.id]
  user_data                   = local.cloud_init
  user_data_replace_on_change = true

  tags = {
    Name  = "${local.awalan}-goreng"
    peran = "goreng"
    versi = "2.1.0"
  }
}
```

Output yang ditambahkan:

```hcl
output "url_goreng" {
  value = var.bandingkan_goreng ? "http://${aws_instance.goreng[0].public_ip}" : null
}
```

Dengan `bandingkan_goreng = false`, plan berakhir `No changes` setelah state sesuai konfigurasi.
Ketika diubah menjadi `true`, plan hanya membuat satu resource:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

## 2. Pengukuran

| Server | Sumber AMI | "Creation complete" | `koma sehat` | Total sampai sehat | Jawaban `/versi` |
|---|---|---:|---:|---:|---|
| api 2.0.0 | AMI milik sendiri `ami-09adba744334290af` | 17 detik | 0,6 detik | sekitar 0,6 detik setelah creation | `2.0.0`, host API internal |
| api 2.1.0 | AMI milik sendiri `ami-093bea1bfbc74a25a` | 18 detik | 0,5 detik | sekitar 0,5 detik setelah creation | `2.1.0`, `ip-172-31-9-225.ap-southeast-2.compute.internal` |
| goreng 2.1.0 | AMI publik `ami-03988d3be5ed1bfdb` + user data | 16 detik | 0,6 detik | sekitar 0,6 detik setelah creation | `2.1.0`, host berbeda dari API |

Perbandingan ini mengukur waktu setelah EC2 melaporkan `Creation complete`; waktu panggang AMI
terjadi sebelumnya dan tidak dihitung sebagai waktu siap server api. Server goreng yang terukur
memakai cloud-init tanpa instalasi paket sehingga selisihnya kecil pada percobaan ini.

## 3. Mengapa selisihnya sebesar itu

Pada server goreng, cloud-init masih harus menulis `/opt/koma/koma_api.py`,
`/etc/koma/koma.env`, dan unit systemd, menjalankan `systemctl daemon-reload`, lalu
`systemctl enable --now koma-api.service` sebelum `/health` menjawab. Server api dari AMI
panggang sudah membawa file aplikasi dan unit service tersebut; saat boot ia terutama perlu
menyalakan service, sehingga waktu setelah `Creation complete` hampir sama.

Jika template harus menjalankan `dnf install`, server goreng akan menunggu repository,
pengunduhan, verifikasi, dan instalasi paket sebelum service aktif. Waktu siap menjadi lebih
panjang dan lebih tidak stabil. Pada percobaan ini security group hanya mengizinkan TCP/80
dari `103.211.143.250/32` dan tidak memiliki aturan egress (`IpPermissionsEgress: []`).
Karena itu, instalasi paket dari internet tidak boleh diasumsikan berhasil; fry harus memakai
AMI publik yang sudah memiliki kebutuhan runtime atau jaringan keluar harus disediakan secara
eksplisit.

## 4. Kapan fry masih masuk akal

Untuk KSL, fry masih masuk akal bagi percobaan singkat, worker sementara, atau komponen
publik berisiko rendah yang memang cukup memakai AMI publik dan konfigurasi runtime kecil.
Portal jadwal dokter yang datanya publik dapat menjadi kandidat terbatas, sesuai E8.

API RME, database, dan komponen yang menangani rekam medis harus dipanggang atau dibangun
dengan pipeline yang terkontrol. E6 menyebut tim platform masih junior dan P3 menunjukkan
alur pendaftaran, rekam medis, laboratorium, resep, serta klaim adalah proses inti. AMI
panggang mengurangi pekerjaan boot dan membuat isi server konsisten; ini sejalan dengan
Morris (2025, hlm. 198), bahwa fry cocok untuk eksperimen/konfigurasi yang berubah cepat,
sedangkan bake lebih tepat untuk rilis yang perlu konsisten dan cepat siap.

## 5. Bukti

- Potret goreng aktif: potret 10, `2026-11-10T12:02:06Z` (WIB `19:02:06`).
- `grep -c "m02-goreng" bukti/bukti-m02.json`: `4` setelah seluruh siklus bukti.
- `bandingkan_goreng` dikembalikan ke `false` dan server goreng terhapus: **ya**.
- Potret bersih terakhir: potret 11, `2026-11-10T12:04:56Z`.
- `latihan_lulus` pada `bukti/bukti-m02.json`: `true`.
