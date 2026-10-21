# ADR-0003 — Secrets per lingkungan, deploy, dan penjadwal

Status: Diterima | Tanggal: 2026-10-21

## Konteks

PWN-OPS-003 (issue #3): secrets per env, deploy compose + k8s dengan DB logis `pawonee` (Postgres 16.x), rotasi service key 90 hari, runbook rollback. Variabel nyata backend (dari `src/config.rs` PR backend #8): `DATABASE_URL`, `JWT_RAHASIA` (min. 32), `PEDAREE_BASE_URL`, `PEDAREE_SERVICE_KEY`, `ALAMAT`, `TIMEOUT_DETIK`. Pipeline memakai `DATABASE_URL`. Bergantung pada ADR-0002 (`qa-gate` dipakai deploy).

## Keputusan

1. Repo hanya memuat templat (`env/*.env.example`, `k8s/secret.example.yaml`); nilai nyata di secret manager / GitHub Environment / `kubectl create secret`. `.gitignore` memblokir `.env*`, `*.pem`, `k8s/secret.yaml`.
2. Compose memakai interpolasi `${VAR:?}` sehingga gagal keras bila secret belum diisi; tidak ada nilai bawaan rahasia.
3. Workflow `deploy` dipicu manual, wajib melewati `qa-gate` (reusable `ci.yml`), tidak pernah menerapkan secret, dan rollback otomatis bila rollout gagal. Rollback manual tersedia (`aksi=rollback`).
4. Penjadwal: sinyal `*/15 * * * *` (CronJob/loop compose) dan agregat mingguan `5 17 * * 0` UTC (= Senin 00.05 WIB, setelah minggu WIB tertutup), keduanya idempoten.
5. Umur rotasi dicek skrip `scripts/ops/cek-rotasi.sh` terhadap `docs/runbook/rotasi-terakhir.txt`; > 90 hari = merah.

## Konsekuensi

- Asumsi: API key per perangkat bukan variabel lingkungan (tidak ada di `config.rs`); diasumsikan diterbitkan backend per perangkat dan disimpan ter-hash di DB `pawonee`. Perlu dikonfirmasi pemilik backend; bila ternyata butuh env, tambahkan ke templat.
- Nama image `ghcr.io/coding-skuy/pawonee-{backend-service,data-pipeline}` dan tag `0.1.0` adalah asumsi; belum ada workflow publish image (di luar lingkup tiket ini).
- Dockerfile backend (main) belum menyalin `Cargo.lock`; kebergantungan build di repo backend.
- Tanggal awal rotasi (2026-10-21) adalah tanggal penetapan jadwal, bukan rotasi nyata.
