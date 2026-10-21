# env/

Hanya `*.env.example` yang boleh masuk git. Berkas `env/*.env` diabaikan (`.gitignore`).

| Variabel | Dipakai | Keterangan |
|---|---|---|
| `DATABASE_URL` | backend, pipeline | DB logis `pawonee`, Postgres 16.x |
| `POSTGRES_PASSWORD` | Postgres | sama dengan sandi di `DATABASE_URL` |
| `JWT_RAHASIA` | backend | min. 32 karakter, audiens `pawonee` |
| `PEDAREE_BASE_URL`, `PEDAREE_SERVICE_KEY` | backend | service key server-ke-server, rotasi 90 hari |
| `ALAMAT`, `TIMEOUT_DETIK`, `RUST_LOG` | backend | opsional |

API key per perangkat: bukan variabel lingkungan; diterbitkan backend per perangkat (lihat catatan di ADR-0003).

Lokal: `docker compose --env-file env/lokal.env up --build`.
