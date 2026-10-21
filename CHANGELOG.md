# CHANGELOG

Format: [Keep a Changelog](https://keepachangelog.com/id-ID/1.1.0/). Versi mengikuti `versions/` TownHall.

## [Belum dirilis]

### Ditambahkan
- PWN-OPS-002: CI QA gate (`qa-gate`) — bank resep 12/12, `cargo test` backend, pytest pipeline, uji Bun web, build APK KMP; skrip `scripts/ci/cek-bank-12.sh` + uji; ADR-0002.
- PWN-OPS-003: templat env per lingkungan, compose + k8s dengan secrets via env/secretKeyRef, CronJob sinyal 15 menit dan agregat mingguan, workflow `deploy` (dengan rollback) dan `rotasi-secret`, runbook deploy/rollback/rotasi, ADR-0003.

## [1.0.0] — 2026-10-14

### Ditambahkan
- Fondasi AI-dev v1.0.0: `AGENTS.md`, `CLAUDE.md`, ADR-0001, `40-TECHSTACK.md`, `60-BLAST-RADIUS.md`.
