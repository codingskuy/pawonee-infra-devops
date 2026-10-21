# Runbook deploy dan rollback (PWN-OPS-003)

Berlaku untuk backend `pawonee-backend-service`, pipeline `pawonee-data-pipeline`, dan Postgres 16.x (DB logis `pawonee`). Reliability: SRS `30-non-functional`.

## 0. Prasyarat (sekali per lingkungan)
1. Namespace: `kubectl create namespace pawonee`.
2. Secret dibuat manual, tidak lewat git (templat `k8s/secret.example.yaml`, daftar variabel `env/README.md`):
   `pawonee-db` (`url`, `password`) dan `pawonee-app` (`jwt-rahasia` >= 32 karakter, `pedaree-base-url`, `pedaree-service-key`).
3. GitHub Environment `staging` dan `produksi` memiliki secret `KUBE_CONFIG_B64` (kubeconfig akun deploy dengan hak terbatas di namespace `pawonee`). Persetujuan manual produksi diatur di Environment oleh pemilik repo.
4. Service key Pedaree bersifat least-privilege (hanya baca stok); jangan pernah memberi akses ke DB divisi lain.

## 1. Deploy
1. Pastikan PR sumber sudah merge dan `qa-gate` hijau (bank 12/12).
2. Catat versi yang berjalan: `kubectl -n pawonee get deploy pawonee-backend -o jsonpath='{.spec.template.spec.containers[0].image}'` dan `kubectl -n pawonee rollout history deploy/pawonee-backend`.
3. Cadangkan DB sebelum migrasi: `kubectl -n pawonee exec sts/pawonee-db -- pg_dump -U pawonee -Fc pawonee > pawonee-$(date +%F).dump` (simpan di luar repo).
4. Jalankan workflow `deploy` (Actions > deploy > Run): `lingkungan`, `aksi=deploy`, `tag_backend`, `tag_pipeline`. Workflow menjalankan `qa-gate`, menerapkan manifest, memasang tag, menunggu rollout, dan membatalkan otomatis bila gagal.
5. Verifikasi: `GET /v1/kesehatan` -> `{"status":"baik","kontrakVersi":...}`; CronJob `pawonee-sinyal-pedaree` berjalan tiap 15 menit (`kubectl -n pawonee get cronjob,job`); log tanpa galat.
6. Backend menjalankan migrasi SQLx otomatis saat start. Jika rilis menambah migrasi, baca bagian 3.

## 2. Rollback aplikasi (tanpa perubahan skema)
- Workflow `deploy` > `aksi=rollback` (menjalankan `kubectl rollout undo deployment/pawonee-backend`), atau manual:
  `kubectl -n pawonee rollout undo deploy/pawonee-backend` lalu `kubectl -n pawonee rollout status deploy/pawonee-backend`.
- Pipeline: pasang tag lama, `kubectl -n pawonee set image cronjob/pawonee-sinyal-pedaree pipeline=ghcr.io/coding-skuy/pawonee-data-pipeline:<tag-lama>` (idem `pawonee-serapan-mingguan`). Pipa idempoten per (`keluarga_id`, `periode_mulai`), aman diulang.
- Waktu target: < 10 menit. Catat insiden dan penyebab di PR/issue.

## 3. Rollback dengan migrasi skema
SQLx `migrate!` tidak menjalankan migrasi balik. Skrip balik ada di repo backend `db/down/*.down.sql` (urutan balik: nomor terbesar dulu).
1. Hentikan lalu-lintas tulis: `kubectl -n pawonee scale deploy/pawonee-backend --replicas=0`.
2. Jalankan `*.down.sql` berurutan terbalik: `kubectl -n pawonee exec -i sts/pawonee-db -- psql -U pawonee -d pawonee -v ON_ERROR_STOP=1 < db/down/<nomor>.down.sql`.
3. Pasang image lama dan skala naik: `rollout undo`, `scale --replicas=2`.
4. Bila skrip balik merusak data: pulihkan dump langkah 1.3 (`pg_restore -U pawonee -d pawonee --clean`).
5. Hapus baris `_sqlx_migrations` migrasi yang dibalik agar migrasi ulang berjalan bersih.

## 4. Penjadwal
| Pekerjaan | Jadwal | Perintah |
|---|---|---|
| `sinyal.pedaree.v1` | `*/15 * * * *` | `python src/pipeline.py --sekali` |
| agregat serapan mingguan | `5 17 * * 0` UTC (Senin 00.05 WIB) | `python src/pipeline.py --serapan-mingguan` |
Backfill minggu tertentu: `--serapan-mingguan --minggu YYYY-MM-DD` (Senin, minggu harus sudah tertutup).

## 5. Lokal
`cp env/lokal.env.example env/lokal.env`, isi nilai, lalu `docker compose --env-file env/lokal.env up --build`. Agregat mingguan manual: `docker compose --env-file env/lokal.env --profile mingguan run --rm pipeline-mingguan`.
