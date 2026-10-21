#!/usr/bin/env bash
# Memeriksa umur rotasi secret (PWN-OPS-003): gagal bila > 90 hari, peringatan mulai 75 hari.
# Pemakaian: scripts/ops/cek-rotasi.sh <berkas rotasi-terakhir.txt> [YYYY-MM-DD hari-ini]
set -euo pipefail

berkas="${1:?pemakaian: cek-rotasi.sh <rotasi-terakhir.txt> [hari-ini]}"
hari_ini="${2:-$(date -u +%F)}"
batas=90
peringatan=75
gagal=0

while IFS='=' read -r nama tanggal; do
  case "$nama" in ''|'#'*) continue ;; esac
  umur="$(python3 -c 'import sys,datetime as d; print((d.date.fromisoformat(sys.argv[2])-d.date.fromisoformat(sys.argv[1])).days)' "$tanggal" "$hari_ini")" || {
    echo "GAGAL: tanggal tidak valid untuk $nama: $tanggal" >&2; exit 2; }
  if [ "$umur" -gt "$batas" ]; then
    echo "GAGAL: $nama terakhir dirotasi $tanggal ($umur hari > $batas); rotasi sekarang." >&2
    gagal=1
  elif [ "$umur" -ge "$peringatan" ]; then
    echo "PERINGATAN: $nama berumur $umur hari (batas $batas); jadwalkan rotasi."
  else
    echo "ok: $nama berumur $umur hari"
  fi
done <"$berkas"
exit "$gagal"
