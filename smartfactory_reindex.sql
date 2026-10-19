/*
  SmartFactory - Chuyen tu Fat (Covering) Index sang Lean Index
  Yeu cau: MySQL 8.0 (dung WITH RECURSIVE va information_schema_stats_expiry).
  Quy trinh: dung he thong cu -> do + EXPLAIN TRUOC -> doi index -> do + EXPLAIN SAU
*/

/* =====================================================
   PHAN 0: Dung lai he thong LEGACY
   ===================================================== */

CREATE DATABASE IF NOT EXISTS smartfactory_db;
USE smartfactory_db;

DROP TABLE IF EXISTS SensorLogs;

CREATE TABLE SensorLogs (
    log_id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    sensor_id   INT NOT NULL,
    recorded_at DATETIME NOT NULL,
    temperature DECIMAL(5,2),
    humidity    DECIMAL(5,2),
    status      VARCHAR(20)          -- 'NORMAL', 'WARNING', 'CRITICAL'
);

-- Fat Index cua ky su cu: nhet tat ca cac cot
CREATE INDEX idx_fat_covering
    ON SensorLogs(sensor_id, recorded_at, temperature, humidity, status);

/* Sinh 300.000 ban ghi mau: 10.000 cam bien, trai deu trong 30 ngay (tu 2026-06-01) */
SET SESSION cte_max_recursion_depth = 300000;

INSERT INTO SensorLogs (sensor_id, recorded_at, temperature, humidity, status)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 300000
)
SELECT 1 + (n % 10000),
       TIMESTAMP('2026-06-01 00:00:00') + INTERVAL (n % 2592000) SECOND,
       ROUND(20 + RAND() * 60, 2),
       ROUND(30 + RAND() * 50, 2),
       ELT(1 + FLOOR(RAND() * 3), 'NORMAL', 'WARNING', 'CRITICAL')
FROM seq;

/* =====================================================
   PHAN 1: DO + EXPLAIN TRUOC KHI DOI INDEX
   ===================================================== */

SET SESSION information_schema_stats_expiry = 0;   -- khong dung thong ke cu trong cache
ANALYZE TABLE SensorLogs;

-- 1.1 Dung luong (xem cot Data_length, Index_length)
SHOW TABLE STATUS LIKE 'SensorLogs';

SELECT table_name,
       table_rows,
       ROUND(data_length  / 1024 / 1024, 2)                 AS data_mb,
       ROUND(index_length / 1024 / 1024, 2)                 AS index_mb,
       ROUND(index_length / data_length, 2)                 AS index_to_data_ratio
FROM information_schema.TABLES
WHERE table_schema = 'smartfactory_db'
  AND table_name   = 'SensorLogs';

SHOW INDEX FROM SensorLogs;

-- 1.2 EXPLAIN truy van Dashboard khi con Fat Index
EXPLAIN SELECT temperature, humidity, status
FROM SensorLogs
WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';
-- Mong doi: key = idx_fat_covering, Extra = Using index (Covering Index)

-- 1.3 Do thoi gian INSERT 20.000 dong khi con Fat Index
SET @t0 = NOW(6);
INSERT INTO SensorLogs (sensor_id, recorded_at, temperature, humidity, status)
WITH RECURSIVE seq AS (
    SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 20000
)
SELECT 1 + (n % 10000),
       TIMESTAMP('2026-07-01 00:00:00') + INTERVAL (n % 2592000) SECOND,
       ROUND(20 + RAND() * 60, 2),
       ROUND(30 + RAND() * 50, 2),
       ELT(1 + FLOOR(RAND() * 3), 'NORMAL', 'WARNING', 'CRITICAL')
FROM seq;
SELECT ROUND(TIMESTAMPDIFF(MICROSECOND, @t0, NOW(6)) / 1000, 1) AS insert_20k_ms_FAT;

/* =====================================================
   PHAN 2: DOI INDEX
   (Tren he thong that nen tao index moi truoc roi moi xoa index cu
    de khong co khoang trong khong co index. O day lam theo thu tu de bai.)
   ===================================================== */

-- Xoa Fat Index
ALTER TABLE SensorLogs DROP INDEX idx_fat_covering;

-- Tao Lean Index: chi giu cac cot dung de LOC / SAP XEP
CREATE INDEX idx_lean_search ON SensorLogs(sensor_id, recorded_at);

/* =====================================================
   PHAN 3: DO + EXPLAIN SAU KHI DOI INDEX
   ===================================================== */

OPTIMIZE TABLE SensorLogs;       -- (tuy chon) xay lai bang, tra dung luong dia
ANALYZE TABLE SensorLogs;

SHOW TABLE STATUS LIKE 'SensorLogs';

SELECT table_name,
       table_rows,
       ROUND(data_length  / 1024 / 1024, 2)                 AS data_mb,
       ROUND(index_length / 1024 / 1024, 2)                 AS index_mb,
       ROUND(index_length / data_length, 2)                 AS index_to_data_ratio
FROM information_schema.TABLES
WHERE table_schema = 'smartfactory_db'
  AND table_name   = 'SensorLogs';

SHOW INDEX FROM SensorLogs;

-- EXPLAIN truy van Dashboard sau khi doi
EXPLAIN SELECT temperature, humidity, status
FROM SensorLogs
WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';
-- Mong doi: key = idx_lean_search, type = range,
--           Extra KHONG con "Using index" (phai lookup them vao bang goc)

-- Do lai thoi gian INSERT 20.000 dong khi chi con Lean Index
SET @t0 = NOW(6);
INSERT INTO SensorLogs (sensor_id, recorded_at, temperature, humidity, status)
WITH RECURSIVE seq AS (
    SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 20000
)
SELECT 1 + (n % 10000),
       TIMESTAMP('2026-08-01 00:00:00') + INTERVAL (n % 2592000) SECOND,
       ROUND(20 + RAND() * 60, 2),
       ROUND(30 + RAND() * 50, 2),
       ELT(1 + FLOOR(RAND() * 3), 'NORMAL', 'WARNING', 'CRITICAL')
FROM seq;
SELECT ROUND(TIMESTAMPDIFF(MICROSECOND, @t0, NOW(6)) / 1000, 1) AS insert_20k_ms_LEAN;
