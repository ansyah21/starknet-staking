# PoC K-1 — Paket GitHub Actions (fork + CI)

**Status: fork OTOMATIS GAGAL.** Token GitHub yang dipakai Idris ditolak GitHub saat
fork (`403 Resource not accessible by integration`, 2026-11-12 ~09:53 WIB) — token yang
sama sebelumnya juga gagal membuat repo (403). Fork harus dibuat manual oleh user
(klik di browser), lalu file-file di paket ini di-push ke fork tersebut.

**Peringatan penting sebelum lanjut:**
- Fork dari repo publik **otomatis PUBLIK** — kode PoC di paket ini menjelaskan celah
  `update_rewards` secara terbuka. Begitu di-push, siapa pun bisa membaca PoC-nya
  sebelum laporan HackenProof di-file (risiko first-reporter). Ini jalan yang user
  pilih sendiri; jangan push sebelum sadar risikonya.
- **Aturan 24 jam:** K-1 ditemukan 2026-11-12, deadline filing ~2026-11-13 pagi WIB.
- **Risiko RAM:** kompilasi target test di VM 6 GB OOM 3x (peak scarb RSS ~5,2 GB).
  Runner `ubuntu-latest` GitHub punya 7 GB — kemungkinan muat, tapi TIDAK dijamin.
  Bila job OOM juga, jalurnya runner lebih besar (16 GB) atau harness minimal.

## Isi paket

| File | Keterangan |
|---|---|
| `src/flow_test/poc_k1_update_rewards.cairo` | File PoC (5.174 byte, sha256 `207167da…79`, byte-identical dengan repo lokal) — JANGAN ubah isinya |
| `src/flow_test.cairo` | Versi termodifikasi (hanya +2 baris registrasi `mod poc_k1_update_rewards;`) |
| `.github/workflows/poc-k1.yml` | Workflow CI: snforge 0.49.0 + scarb 2.12.0, menjalankan 1 test PoC |
| `poc-k1.patch` | Patch gabungan kedua file di atas (terverifikasi: apply bersih di clone murni @ 7a7add2) |

Test yang dijalankan: `snforge test poc_k1_update_rewards_arbitrary_caller_captures_full_block_reward --exact`
(dari root repo). PASS = `1 passed`.

## Langkah manual (urutan persis)

### 1. Fork repo di browser
1. Buka https://github.com/starkware-libs/starknet-staking
2. Klik tombol **Fork** (kanan atas) → pilih owner **ansyah21** → **Create fork**.
3. Hasil: https://github.com/ansyah21/starknet-staking

### 2. Pastikan Actions aktif di fork
Di fork → **Settings → Actions → General** → pilih **"Allow all actions and reusable
workflows"** → Save. (Biasanya sudah aktif di fork baru; cek ini bila workflow tidak jalan.)

### 3. Clone fork, salin file, push branch `poc-k1`
Di terminal (komputer user):

```bash
git clone https://github.com/ansyah21/starknet-staking.git
cd starknet-staking
git checkout -b poc-k1
```

Salin file dari paket ini ke dalam clone:
- `src/flow_test/poc_k1_update_rewards.cairo` → `src/flow_test/`
- `src/flow_test.cairo` → `src/` (timpa file yang ada)
- `.github/workflows/poc-k1.yml` → `.github/workflows/`

(Alternatif: `git apply poc-k1.patch` di root clone, lalu salin workflow seperti di atas.)

```bash
git add src/flow_test/poc_k1_update_rewards.cairo src/flow_test.cairo .github/workflows/poc-k1.yml
git commit -m "PoC K-1: arbitrary caller captures full block reward (audit PoC)"
git push -u origin poc-k1
```

### 4. Pantau workflow
Push ke branch `poc-k1` otomatis memicu workflow **"PoC K-1"**.
Lihat di: https://github.com/ansyah21/starknet-staking/actions
(Atau manual: tab **Actions** → **PoC K-1** → **Run workflow**.)

- **Hijau + `1 passed` di log = PoC LULUS → siap filing ke HackenProof.**
- **Merah** = baca log: bila `Killed` / OOM saat kompilasi, runner 7 GB tidak cukup.

### 5. Laporkan hasilnya ke Idris
Kirim URL run + PASS/FAIL. **Jangan submit apa pun ke HackenProof sebelum PoC lulus.**
