# Rotasi secret (PWN-OPS-003)

Aturan: service key server-ke-server dirotasi setiap 90 hari (AGENTS aturan 9). `JWT_RAHASIA` dirotasi minimal setahun atau saat dicurigai bocor. Tanggal rotasi terakhir dicatat di `docs/runbook/rotasi-terakhir.txt` (bukan nilai rahasia); workflow `rotasi-secret` memeriksanya tiap Senin: peringatan mulai 75 hari, GAGAL bila > 90 hari.

## Service key Pedaree
1. Minta pemilik Pedaree menerbitkan key BARU (least-privilege, hanya baca stok) sambil key lama tetap valid (tumpang tindih).
2. Perbarui secret: `kubectl -n pawonee create secret generic pawonee-app --from-literal=jwt-rahasia=<tetap> --from-literal=pedaree-base-url=<url> --from-literal=pedaree-service-key=<baru> --dry-run=client -o yaml | kubectl apply -f -` (jalankan dari terminal aman; jangan menyimpan hasil di git/riwayat bersama).
3. `kubectl -n pawonee rollout restart deploy/pawonee-backend`; verifikasi `GET /v1/stok` bukan 502.
4. Minta pemilik Pedaree mencabut key lama.
5. PR kecil: perbarui tanggal di `rotasi-terakhir.txt`.

## JWT_RAHASIA
Mengganti kunci membatalkan semua token (akses 15 menit, refresh 7 hari): pengguna login ulang. Lakukan di luar jam sibuk; langkah sama seperti di atas (`openssl rand -base64 48`).

## Sandi DB
Ubah sandi role `pawonee` dengan `ALTER ROLE`, perbarui `pawonee-db` (`url` dan `password`), restart backend dan CronJob berikutnya akan memakai nilai baru.

## Bila bocor
Rotasi segera di luar jadwal, cabut yang lama, periksa log akses, catat insiden.
