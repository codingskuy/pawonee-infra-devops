#!/usr/bin/env bash
# Uji merah-hijau untuk cek-bank-12.sh memakai evaluator palsu (tanpa jaringan).
set -euo pipefail
akar="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/eval"

buat() { printf 'print("%s")\nraise SystemExit(%s)\n' "$1" "$2" >"$tmp/eval/evaluate.py"; }
harapkan() { # <nama> <kode-harapan> <ringkasan stdout evaluator> <kode evaluator>
  buat "$3" "$4"
  set +e; "$akar/cek-bank-12.sh" "$tmp" >/dev/null 2>&1; kode=$?; set -e
  if [ "$kode" -ne "$2" ]; then echo "UJI GAGAL: $1 (kode $kode, harap $2)"; exit 1; fi
  echo "ok: $1"
}

harapkan "12/12 lolos"            0 "12/12 resep lolos grade-2." 0
harapkan "11/12 -> blokir"        1 "11/12 resep lolos grade-2." 1
harapkan "11/12 tapi kode 0"      1 "11/12 resep lolos grade-2." 0
harapkan "13/13 (resep ke-13)"    1 "13/13 resep lolos grade-2." 0
harapkan "12/12 tapi kode non-nol" 1 "12/12 resep lolos grade-2." 1
echo "semua uji lulus"
