#!/usr/bin/env bash
# Gerbang crash-free (PWN-OPS-004): lulus bila persentase >= ambang (bawaan 99.5).
# Pemakaian: scripts/release/cek-crashfree.sh <persen, mis. 99.62> [ambang]
set -euo pipefail

persen="${1:?pemakaian: cek-crashfree.sh <persen> [ambang]}"
ambang="${2:-99.5}"

lolos="$(python3 - "$persen" "$ambang" <<'PY'
import sys
from decimal import Decimal, InvalidOperation
try:
    p, a = Decimal(sys.argv[1]), Decimal(sys.argv[2])
except InvalidOperation:
    print("invalid"); raise SystemExit
if not (Decimal(0) <= p <= Decimal(100)):
    print("invalid")
else:
    print("ya" if p >= a else "tidak")
PY
)"

case "$lolos" in
  ya)  echo "OK: crash-free ${persen}% >= ${ambang}%." ;;
  tidak) echo "GAGAL: crash-free ${persen}% < ${ambang}%; jangan naikkan tahap/produksi." >&2; exit 1 ;;
  *)   echo "GAGAL: masukan persen tidak valid: ${persen}" >&2; exit 2 ;;
esac
