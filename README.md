# Kuis 3: Web API dan State Management

## Data Anggota Kelompok 24

- Ahmad Taufiq Hidayat (2202074)

- Themy Sabri Syuhada (2203903)

## Janji

Kami berjanji tidak berbuat curang maupun membantu orang lain berbuat curang.

## Deskripsi Program

Aplikasi Flutter ini dibuat sebagai bagian dari tugas Provis kuis API pada bulan Mei 2024. Aplikasi ini terhubung dengan web API FastAPI dan menyediakan fitur autentikasi menggunakan token OAuth. Setelah pengguna berhasil login, mereka akan langsung diarahkan ke halaman utama yang menampilkan daftar makanan yang tersedia untuk dibeli. Pengguna dapat menambahkan makanan ke keranjang belanja, melihat isi keranjang belanja, dan melakukan proses checkout untuk pembayaran.

## Alur Program

1. Pengguna membuka aplikasi dan masuk ke halaman "On-Going Orders".
2. Aplikasi akan melakukan pengambilan status pesanan pengguna dari server menggunakan permintaan HTTP GET.
3. Status pesanan akan ditampilkan di layar.
4. Jika status pesanan adalah "belum_bayar", tombol "Bayar" akan muncul. Pengguna dapat menekan tombol tersebut untuk melakukan pembayaran.
5. Jika status pesanan berubah menjadi "terima_bayar", tombol "Set Penjual Terima" dan "Set Penjual Tolak" akan muncul. Pengguna dapat menekan salah satu tombol tersebut untuk mengonfirmasi status pesanan oleh penjual.
6. Jika status pesanan berubah menjadi "diantar", tombol "Set Diantar" akan muncul. Pengguna dapat menekan tombol tersebut untuk mengonfirmasi bahwa pesanan telah diantar.
7. Jika status pesanan berubah menjadi "diterima", tombol "Pesanan Diterima" akan muncul. Pengguna dapat menekan tombol tersebut untuk mengonfirmasi bahwa pesanan telah diterima.

## Kontributor

- Ahmad Taufiq Hidayat ([@artefiq](https://github.com/artefiq))
- Themy Sabri Syuhada ([@ThemySabri](https://github.com/ThemySabri))
