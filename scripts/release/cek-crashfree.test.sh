#!/usr/bin/env bash
# Uji merah-hijau untuk cek-crashfree.sh.
set -euo pipefail
akar="$(cd "$(dirname "$0")" && pwd)"

harapkan() { # <nama> <kode-harapan> <persen> [ambang]
  set +e; "$akar/cek-crashfree.sh" "${@:3}" >/dev/null 2>&1; kode=$?; set -e
  if [ "$kode" -ne "$2" ]; then echo "UJI GAGAL: $1 (kode $kode, harap $2)"; exit 1; fi
  echo "ok: $1"
}

harapkan "99.62 lolos"          0 99.62
harapkan "tepat 99.5 lolos"     0 99.5
harapkan "99.49 gagal"          1 99.49
harapkan "100 lolos"            0 100
harapkan "ambang kustom 99.9"   1 99.8 99.9
harapkan "di luar 0..100"       2 101
harapkan "bukan angka"          2 abc
echo "semua uji lulus"
