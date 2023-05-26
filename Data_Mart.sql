-- Membuat tabel sementara untuk menampung data penjualan setelah penyesuaian harga
CREATE TABLE penjualan_all AS
SELECT id_invoice, tanggal, id_customer, id_barang, jumlah_barang, unit, harga
FROM (
  -- Query untuk mengupdate harga pada tabel finalproject.penjualan
  SELECT 
    id_invoice, tanggal, id_customer, id_barang, jumlah_barang, unit, 
    CASE
      WHEN id_barang = 'BRG0005' THEN 47000 -- Update harga untuk barang BRG0005
      WHEN id_barang = 'BRG0010' THEN 21000 -- Update harga untuk barang BRG0010
      ELSE harga
    END AS harga
  FROM finalproject.penjualan
) penjualan_harga;

-- Membuat tabel salicyl_database dari tabel penjualan_all
CREATE TABLE salicyl_database AS (
  SELECT
    pa.tanggal,
    pa.id_invoice,
    pa.id_customer,
    pl.nama AS nama_pelanggan,
    pl.cabang_sales,
    pl.group,
    pl.id_distributor,
    pa.id_barang,
    ba.nama_barang,
    pa.unit,
    pa.harga,
    pa.jumlah_barang,
    pa.harga * pa.jumlah_barang AS harga_total
  FROM penjualan_all pa
  JOIN barang_ds ba ON pa.id_barang  = ba.kode_barang
  JOIN pelanggan_ds pl ON pa.id_customer = pl.id_customer
  WHERE pa.id_barang IN ('BRG0005', 'BRG0010')
);

-- Query untuk menampilkan data aggregat dari tabel salicyl_database
CREATE TABLE sales_date AS( -- Menghitung total penjualan per tanggal 
SELECT tanggal, SUM(harga_total) AS total_penjualan
FROM salicyl_database
GROUP BY tanggal);

CREATE TABLE total_customer AS( -- Menghitung total penjualan per pelanggan
SELECT id_customer, nama_pelanggan, SUM(harga_total) AS total_penjualan
FROM salicyl_database
GROUP BY id_customer, nama_pelanggan);

CREATE TABLE total_sales_per_customer AS( -- Menghitung total penjualan per produk
SELECT id_barang, nama_barang, SUM(jumlah_barang) AS total_barang_terjual, SUM(harga_total) AS total_penjualan
FROM salicyl_database
GROUP BY id_barang, nama_barang);

CREATE TABLE total_sales_per_branch AS( -- Menghitung total penjualan per cabang sales
SELECT cabang_sales, SUM(harga_total) AS total_penjualan
FROM salicyl_database
GROUP BY cabang_sales);