#!/usr/bin/env bash
# Gerbang QA bank resep (PWN-OPS-002): lulus hanya bila evaluasi melaporkan tepat 12/12.
# Pemakaian: scripts/ci/cek-bank-12.sh <direktori pawonee-ai-models>
set -euo pipefail

dir="${1:?pemakaian: cek-bank-12.sh <direktori pawonee-ai-models>}"
python_bin="${PYTHON:-python3}"

keluaran="$("$python_bin" "$dir/eval/evaluate.py")" || {
  echo "$keluaran"
  echo "GAGAL: evaluate.py keluar non-nol; rilis diblokir." >&2
  exit 1
}
echo "$keluaran"

if ! grep -qE '^12/12 resep lolos' <<<"$keluaran"; then
  echo "GAGAL: bank resep harus 12/12 (bukan kurang, bukan lebih); rilis diblokir." >&2
  exit 1
fi
echo "OK: bank resep 12/12."
