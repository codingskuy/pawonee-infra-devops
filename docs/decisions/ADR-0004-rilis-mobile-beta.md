# ADR-0004 — Jalur rilis mobile beta

Status: Diterima | Tanggal: 2026-10-21

## Konteks

PWN-OPS-004 (issue #4): distribusi Android + iOS untuk beta bertahap (20 keluarga hari 1-30, 100 keluarga hari 31-60) dengan gerbang crash-free >= 99,5% dan artefak build per versi. Windows tidak berlaku. Bergantung pada ADR-0002 (`qa-gate`). Nomor 0004 dipilih agar tidak bentrok dengan ADR-0003 (PWN-OPS-003, secrets/deploy).

## Keputusan

1. Tiga jalur: APK sideload, Play internal testing, TestFlight; semua di belakang `qa-gate`.
2. Kredensial hanya di GitHub Environment `mobile-beta`; workflow tanpa kredensial turun ke mode aman (APK debug tak-bertanda, atau tidak melakukan apa pun untuk iOS dengan peringatan).
3. Artefak per versi: `pawonee-android-<versi>` dan `pawonee-ios-<versi>` (retention 90 hari) + `SHA256SUMS.txt`.
4. Gerbang crash-free diperiksa skrip dan dicatat di ringkasan run `gerbang-crashfree`; angka diinput operator dari dasbor.

## Konsekuensi

- Path Gradle/Xcode adalah asumsi sampai `pawonee-app-kmp` memiliki `gradlew`, modul Android, dan `iosApp/`.
- Alat pemantau crash iOS belum ditetapkan di dokumen; perlu keputusan manusia.
- Pengumpulan crash-free otomatis (API Play Developer Reporting) ditunda; input manual dipilih agar tanpa kredensial tambahan.
