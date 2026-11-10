variable "nim" {
  type        = string
  description = "NIM praktikan; dipakai di tag dan nama resource"
  validation {
    condition     = can(regex("^[0-9]{8,10}$", var.nim))
    error_message = "NIM harus 8-10 digit angka."
  }
}

variable "kelompok" {
  type        = string
  description = "ID kelompok kasus (k01-k05; k00 contoh dosen)"
  validation {
    condition     = can(regex("^k0[0-5]$", var.kelompok))
    error_message = "Kelompok harus k01-k05 (k00 untuk contoh dosen)."
  }
}

variable "region" {
  type        = string
  default     = "ap-southeast-2"
  description = "Region proyek AWS (Indonesia: ap-southeast-2)"
}

variable "layanan" {
  type = map(object({
    peran  = string
    ukuran = string
    os     = string
  }))
  description = "Katalog layanan kasus; ukuran memakai preset praktikum."
  default = {
    portal-pasien = {
      peran  = "web"
      ukuran = "t3.micro"
      os     = "al2023"
    }
    api-rme = {
      peran  = "api"
      ukuran = "t3.small"
      os     = "al2023"
    }
    worker-lab = {
      peran  = "worker"
      ukuran = "t3.micro"
      os     = "al2023"
    }
  }
  validation {
    condition     = length(var.layanan) >= 2 && length(var.layanan) <= 3
    error_message = "Katalog layanan harus berisi dua atau tiga entri."
  }
  validation {
    condition     = length(distinct([for layanan in values(var.layanan) : layanan.peran])) >= 2
    error_message = "Katalog layanan harus memiliki sekurangnya dua peran berbeda."
  }
  validation {
    condition = alltrue([
      for k, layanan in var.layanan :
      can(regex("^[a-z0-9][a-z0-9-]*$", k)) &&
      contains(["t3.micro", "t3.small"], layanan.ukuran) &&
      layanan.os == "al2023"
    ])
    error_message = "Kunci harus kebab-case; ukuran harus t3.micro/t3.small; os harus al2023."
  }
}
