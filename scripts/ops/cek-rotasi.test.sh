#!/usr/bin/env bash
# Uji merah-hijau untuk cek-rotasi.sh dengan tanggal acuan tetap.
set -euo pipefail
akar="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

harapkan() { # <nama> <kode-harapan> <isi berkas> <hari-ini>
  printf '%s\n' "$3" >"$tmp/r.txt"
  set +e; "$akar/cek-rotasi.sh" "$tmp/r.txt" "$4" >/dev/null 2>&1; kode=$?; set -e
  if [ "$kode" -ne "$2" ]; then echo "UJI GAGAL: $1 (kode $kode, harap $2)"; exit 1; fi
  echo "ok: $1"
}

harapkan "baru (10 hari)"        0 "k=2026-10-01" 2026-10-11
harapkan "tepat 90 hari lolos"   0 "k=2026-01-01" 2026-04-01
harapkan "91 hari gagal"         1 "k=2026-01-01" 2026-04-02
harapkan "satu lama, satu baru"  1 $'a=2026-10-01\nb=2025-01-01' 2026-10-11
harapkan "komentar diabaikan"    0 $'# catatan\nk=2026-10-01' 2026-10-11
harapkan "tanggal rusak"         2 "k=bukan-tanggal" 2026-10-11
echo "semua uji lulus"
