# Kuis 3: Web API dan State Management

## Data Anggota Kelompok 24

- Ahmad Taufiq Hidayat (2202074)

- Themy Sabri Syuhada (2203903)

## Janji

Kami berjanji tidak berbuat curang maupun membantu orang lain berbuat curang.

## Deskripsi Program

Program ini adalah sebuah aplikasi Flutter yang dirancang untuk mengelola status pesanan pengguna. Aplikasi ini memungkinkan pengguna untuk melakukan berbagai tindakan terkait status pesanan mereka, seperti melakukan pembayaran, mengonfirmasi penerimaan atau penolakan pesanan oleh penjual, serta mengonfirmasi penerimaan pesanan oleh pengguna.

## Alur Program

1. Pengguna membuka aplikasi dan masuk ke halaman "On-Going Orders".
2. Aplikasi akan melakukan pengambilan status pesanan pengguna dari server menggunakan permintaan HTTP GET.
3. Status pesanan akan ditampilkan di layar.
4. Jika status pesanan adalah "belum_bayar", tombol "Bayar" akan muncul. Pengguna dapat menekan tombol tersebut untuk melakukan pembayaran.
5. Jika status pesanan berubah menjadi "terima_bayar", tombol "Set Penjual Terima" dan "Set Penjual Tolak" akan muncul. Pengguna dapat menekan salah satu tombol tersebut untuk mengonfirmasi status pesanan oleh penjual.
6. Jika status pesanan berubah menjadi "diantar", tombol "Set Diantar" akan muncul. Pengguna dapat menekan tombol tersebut untuk mengonfirmasi bahwa pesanan telah diantar.
7. Jika status pesanan berubah menjadi "diterima", tombol "Pesanan Diterima" akan muncul. Pengguna dapat menekan tombol tersebut untuk mengonfirmasi bahwa pesanan telah diterima.
