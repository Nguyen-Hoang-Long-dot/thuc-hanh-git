/*
  QuickFeed - Index optimization
  Yeu cau: MySQL 8.0 (dung WITH RECURSIVE va information_schema_stats_expiry).
  Quy trinh: tao lai he thong cu -> do TRUOC -> DROP 3 index vo dung -> do SAU
*/

/* =====================================================
   PHAN 0: Dung lai he thong LEGACY (5 index)
   ===================================================== */

CREATE DATABASE IF NOT EXISTS quickfeed_db;
USE quickfeed_db;

DROP TABLE IF EXISTS Posts;

CREATE TABLE Posts (
    post_id    INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    content    TEXT,
    post_type  VARCHAR(10),            -- chi 3 gia tri: TEXT, IMAGE, VIDEO
    is_visible BOOLEAN DEFAULT 1,      -- chi 2 gia tri: 1 / 0
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_id    ON Posts(user_id);
CREATE INDEX idx_content    ON Posts(content(255));
CREATE INDEX idx_post_type  ON Posts(post_type);
CREATE INDEX idx_is_visible ON Posts(is_visible);
CREATE INDEX idx_created_at ON Posts(created_at);

/* Sinh 100.000 bai viet mau de dung luong du lon de so sanh */
SET SESSION cte_max_recursion_depth = 100000;

INSERT INTO Posts (user_id, content, post_type, is_visible, created_at)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 100000
)
SELECT 1 + FLOOR(RAND() * 5000),
       CONCAT('Noi dung bai viet so ', n, ' - ', MD5(RAND()), MD5(RAND()), REPEAT(' lorem ipsum', 25)),
       ELT(1 + (n % 3), 'TEXT', 'IMAGE', 'VIDEO'),
       IF(n % 100 = 0, 0, 1),                       -- 99% bai viet dang hien
       NOW() - INTERVAL FLOOR(RAND() * 31536000) SECOND
FROM seq;

/* =====================================================
   PHAN 1: DO TRUOC KHI TOI UU
   ===================================================== */

SET SESSION information_schema_stats_expiry = 0;   -- khong dung thong ke cu trong cache
ANALYZE TABLE Posts;

-- 1.1 Cach 1: SHOW TABLE STATUS (xem cot Data_length, Index_length)
SHOW TABLE STATUS LIKE 'Posts';

-- 1.2 Cach 2: information_schema, don vi MB
SELECT table_name,
       table_rows,
       ROUND(data_length  / 1024 / 1024, 2)                 AS data_mb,
       ROUND(index_length / 1024 / 1024, 2)                 AS index_mb,
       ROUND((data_length + index_length) / 1024 / 1024, 2) AS total_mb,
       ROUND(index_length / data_length, 2)                 AS index_to_data_ratio
FROM information_schema.TABLES
WHERE table_schema = 'quickfeed_db'
  AND table_name   = 'Posts';

-- 1.3 Cardinality tung index (cot Cardinality): so sanh voi table_rows
SHOW INDEX FROM Posts;

-- 1.4 Do thoi gian INSERT 20.000 dong khi con 5 index
SET @t0 = NOW(6);
INSERT INTO Posts (user_id, content, post_type, is_visible, created_at)
WITH RECURSIVE seq AS (
    SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 20000
)
SELECT 1 + FLOOR(RAND() * 5000),
       CONCAT('Noi dung moi ', n, ' - ', MD5(RAND()), MD5(RAND()), REPEAT(' lorem ipsum', 25)),
       ELT(1 + (n % 3), 'TEXT', 'IMAGE', 'VIDEO'),
       IF(n % 100 = 0, 0, 1),
       NOW() - INTERVAL FLOOR(RAND() * 31536000) SECOND
FROM seq;
SELECT ROUND(TIMESTAMPDIFF(MICROSECOND, @t0, NOW(6)) / 1000, 1) AS insert_20k_ms_BEFORE;

/* =====================================================
   PHAN 2: LOAI BO 3 INDEX VO DUNG
   Giu lai: idx_user_id, idx_created_at
   ===================================================== */

-- Cot TEXT, B-Tree phinh to, khong ho tro tim kiem tu khoa tot
ALTER TABLE Posts DROP INDEX idx_content;

-- Cardinality = 3
ALTER TABLE Posts DROP INDEX idx_post_type;

-- Cardinality = 2
ALTER TABLE Posts DROP INDEX idx_is_visible;

-- (Tuy chon) Xay lai bang de tra dung luong dia ve he dieu hanh
OPTIMIZE TABLE Posts;

/* =====================================================
   PHAN 3: DO SAU KHI TOI UU
   ===================================================== */

ANALYZE TABLE Posts;

SHOW TABLE STATUS LIKE 'Posts';

SELECT table_name,
       table_rows,
       ROUND(data_length  / 1024 / 1024, 2)                 AS data_mb,
       ROUND(index_length / 1024 / 1024, 2)                 AS index_mb,
       ROUND((data_length + index_length) / 1024 / 1024, 2) AS total_mb,
       ROUND(index_length / data_length, 2)                 AS index_to_data_ratio
FROM information_schema.TABLES
WHERE table_schema = 'quickfeed_db'
  AND table_name   = 'Posts';

-- Chi con 2 index (ngoai PRIMARY)
SHOW INDEX FROM Posts;

-- Do lai thoi gian INSERT 20.000 dong khi con 2 index
SET @t0 = NOW(6);
INSERT INTO Posts (user_id, content, post_type, is_visible, created_at)
WITH RECURSIVE seq AS (
    SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 20000
)
SELECT 1 + FLOOR(RAND() * 5000),
       CONCAT('Noi dung moi ', n, ' - ', MD5(RAND()), MD5(RAND()), REPEAT(' lorem ipsum', 25)),
       ELT(1 + (n % 3), 'TEXT', 'IMAGE', 'VIDEO'),
       IF(n % 100 = 0, 0, 1),
       NOW() - INTERVAL FLOOR(RAND() * 31536000) SECOND
FROM seq;
SELECT ROUND(TIMESTAMPDIFF(MICROSECOND, @t0, NOW(6)) / 1000, 1) AS insert_20k_ms_AFTER;

/* =====================================================
   THAM KHAO: tim kiem tu khoa trong content dung FULLTEXT
   (khong chay mac dinh, bo comment neu muon thu)
   ===================================================== */
-- ALTER TABLE Posts ADD FULLTEXT INDEX ft_content (content);
-- SELECT post_id FROM Posts
-- WHERE MATCH(content) AGAINST('lorem' IN NATURAL LANGUAGE MODE) LIMIT 10;
