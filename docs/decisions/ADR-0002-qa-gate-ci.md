# ADR-0002 — QA gate CI lintas repo

Status: Diterima | Tanggal: 2026-10-21

## Konteks

PWN-OPS-002 (issue #2): CI harus menjalankan `cargo test`, uji web Bun, build APK KMP, dan evaluasi bank resep; rilis diblokir bila bank < 12/12 (SRS QA-001..QA-004). Repo terkait masih bergerak: backend PR #6-#8, data-pipeline PR #5-#7, web masih Next.js (drift, PWN-WEB-005), app-kmp belum punya `gradlew`.

## Keputusan

1. `ci.yml` mengambil repo lain lewat `actions/checkout` (`CROSS_REPO_TOKEN` bila ada, jatuh ke `github.token`); ref tiap repo bisa dipilih lewat `workflow_dispatch`/`workflow_call` sehingga PR yang belum merge bisa diuji.
2. Job `qa-gate` adalah satu-satunya status wajib: hijau hanya bila SEMUA job lain `success` (job yang di-skip dihitung merah). Tidak ada `continue-on-error` pada jalur uji.
3. Gerbang bank memakai `scripts/ci/cek-bank-12.sh` (tepat `12/12 resep lolos`, kode keluar evaluator juga diperiksa), diuji merah-hijau oleh `cek-bank-12.test.sh`.
4. Job web, pipeline, dan APK mendeteksi apakah ref sudah memiliki suite (SvelteKit, `tests/`, `gradlew`). Bila belum, job hijau dengan `::warning` eksplisit. Ini sengaja: menggagalkan job karena kode yang memang belum ada akan memblokir semua PR; peringatan harus dihapus (job menjadi wajib) setelah PWN-WEB-005, PWN-DATA-002..004, dan build KMP merge.
5. Cakupan (QA-004) dilaporkan lewat `cargo llvm-cov` ke ringkasan job dan belum menggagalkan build; ambang > 80% jalur kritis ditetapkan per sprint oleh tim.

## Konsekuensi

- Proteksi branch `main` sebaiknya mewajibkan status `qa-gate` (usulan; pengaturan repo tidak diubah oleh PR ini).
- Hijau saat suite belum ada bukan bukti kualitas: baca peringatan job.
- Aturan wajib bank 12 resep: resep ke-13 (13/13) juga memblokir rilis (perluasan masuk v2.0.0).
