# Jalur rilis mobile beta Pawonee (PWN-OPS-004)

Platform: Android + iOS saja. MSIX/EXE Windows TIDAK berlaku untuk Pawonee. Sumber jadwal: `roadmap/TIMELINE.md` (Pawonee-TownHall), tahap beta di bawah.

## Tahap beta (bertahap)
| Tahap | Hari beta | Peserta | Syarat naik tahap |
|---|---|---|---|
| 1 | 1-30 | 20 keluarga | gerbang crash-free >= 99,5% (workflow `gerbang-crashfree`); buka rekomendasi 70% (target TIMELINE) |
| 2 | 31-60 | 100 keluarga | gerbang crash-free >= 99,5%; pipa sinyal berjalan; dasbor serapan terbit |
| 3 | 61-90 | kesiapan lepas beta | crash-free 99,5% tercatat, paritas 32 kasus, audit konten 12 resep |

Sebelum produksi: crash-free >= 99,5% harus tercatat. Catat tiap keputusan naik tahap dengan menjalankan `gerbang-crashfree` (angka dari dasbor); ringkasan run adalah jejak audit.

## Tiga jalur distribusi
| Jalur | Workflow | Keluaran | Penerima |
|---|---|---|---|
| APK sideload | `mobile-android` (`jalur=apk-sideload`) | APK + AAB + `SHA256SUMS.txt` sebagai artefak `pawonee-android-<versi>` (90 hari) | tautan unduh internal; wajib verifikasi SHA-256 |
| Play internal testing | `mobile-android` (`jalur=play-internal`) | AAB ke track `internal` | daftar penguji Play Console |
| TestFlight | `mobile-ios` | IPA (`pawonee-ios-<versi>`) + unggah TestFlight | penguji internal/eksternal TestFlight |

Pemicu: tag `mobile-v<versi>` (mis. `mobile-v0.1.0-beta.1`) atau `workflow_dispatch`. Setiap jalur menjalankan `qa-gate` (ci.yml) lebih dulu; build gagal bila uji merah atau bank < 12/12. Artefak build KMP tersimpan per versi di Actions (retention 90 hari); simpan salinan permanen APK/AAB yang dibagikan ke penguji di penyimpanan rilis.

## Kredensial (hanya di GitHub Environment `mobile-beta`, TIDAK di repo)
Android: `ANDROID_KEYSTORE_B64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `PLAY_SERVICE_ACCOUNT_JSON`; variabel `ANDROID_PACKAGE_NAME`.
iOS: `IOS_CERT_P12_B64`, `IOS_CERT_P12_PASSWORD`, `IOS_PROVISIONING_PROFILE_B64`, `APPSTORE_ISSUER_ID`, `APPSTORE_KEY_ID`, `APPSTORE_PRIVATE_KEY`.
Lintas repo (opsional): `CROSS_REPO_TOKEN` (baca-saja).
Tanpa keystore, workflow Android hanya membangun APK debug tak-bertanda (nama artefak berakhiran `-debug-taktandai`; jangan dibagikan ke keluarga). Tanpa kredensial Apple, `mobile-ios` hanya memberi peringatan. Rotasi mengikuti `docs/runbook/rotasi-secret.md`.

## Pemantauan crash-free
- Android: Play Console > Android vitals (crash-free pengguna).
- iOS: Crashlytics/Xcode Organizer (asumsi alat; belum ditetapkan di dokumen TownHall, perlu keputusan manusia).
- Ambang 99,5% diperiksa `scripts/release/cek-crashfree.sh` (uji: `cek-crashfree.test.sh`).

## Rollback rilis mobile
- Play: hentikan rollout (halt) dan promosikan build sebelumnya di track internal.
- TestFlight: kedaluwarsakan build bermasalah di App Store Connect, kembali ke build sebelumnya.
- APK sideload: cabut tautan unduh, umumkan versi pengganti, minta penguji menghapus-pasang.
- Catat insiden di tiket; kontrak API tidak berubah oleh rilis klien (`X-Kontrak-Versi`).

## Yang belum bisa dijalankan (asumsi)
- `pawonee-app-kmp` main belum punya `gradlew`, modul `:composeApp` Android, maupun proyek `iosApp/`; path build dan skema di workflow adalah asumsi sampai app-kmp menyediakannya.
- Unggah Play/TestFlight belum pernah dijalankan (butuh kredensial nyata).
