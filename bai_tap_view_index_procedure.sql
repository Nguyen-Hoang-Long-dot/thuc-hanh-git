/*
  Bai tap: Luyen tap view, index, stored procedure tren bang Products
*/

/* =====================================================
   BUOC 1: Tao co so du lieu demo
   ===================================================== */

CREATE DATABASE IF NOT EXISTS demo;
USE demo;

/* =====================================================
   BUOC 2: Tao bang Products va chen du lieu mau
   ===================================================== */

DROP TABLE IF EXISTS Products;

CREATE TABLE Products (
    Id                 INT AUTO_INCREMENT PRIMARY KEY,
    productCode        VARCHAR(20)   NOT NULL,
    productName        VARCHAR(100)  NOT NULL,
    productPrice       DECIMAL(12,2) NOT NULL,
    productAmount      INT           NOT NULL DEFAULT 0,
    productDescription VARCHAR(255)  DEFAULT NULL,
    productStatus      VARCHAR(20)   NOT NULL DEFAULT 'Available'
);

INSERT INTO Products
    (productCode, productName, productPrice, productAmount, productDescription, productStatus)
VALUES
    ('P001', 'iPhone 15',         999.00, 50,  'Dien thoai Apple',        'Available'),
    ('P002', 'Samsung Galaxy S24', 899.00, 40,  'Dien thoai Samsung',      'Available'),
    ('P003', 'Laptop Dell XPS',   1500.00, 20,  'Laptop van phong cao cap', 'Available'),
    ('P004', 'MacBook Air M2',    1200.00, 15,  'Laptop Apple',            'Available'),
    ('P005', 'iPad Pro',          1100.00, 25,  'May tinh bang Apple',     'Available'),
    ('P006', 'Tai nghe AirPods',   249.00, 100, 'Tai nghe khong day',      'Available'),
    ('P007', 'Chuot Logitech',      49.00, 200, 'Chuot khong day',         'Available'),
    ('P008', 'Ban phim co',         89.00, 0,   'Ban phim co RGB',         'Out of stock'),
    ('P009', 'Man hinh LG 27 inch', 320.00, 30, 'Man hinh 4K',             'Available'),
    ('P010', 'Loa JBL',            150.00, 0,   'Loa bluetooth',           'Out of stock');

SELECT * FROM Products;

/* =====================================================
   BUOC 3: Index va EXPLAIN
   ===================================================== */

-- 3.1 EXPLAIN TRUOC khi tao index
EXPLAIN SELECT * FROM Products WHERE productCode = 'P003';
-- Mong doi: type = ALL (quet toan bang), key = NULL

EXPLAIN SELECT * FROM Products
WHERE productName = 'Laptop Dell XPS' AND productPrice = 1500.00;
-- Mong doi: type = ALL, key = NULL

-- 3.2 Tao Unique Index tren productCode
CREATE UNIQUE INDEX idx_productCode ON Products(productCode);

-- 3.3 Tao Composite Index tren productName va productPrice
CREATE INDEX idx_productName_price ON Products(productName, productPrice);

SHOW INDEX FROM Products;

-- 3.4 EXPLAIN SAU khi tao index
EXPLAIN SELECT * FROM Products WHERE productCode = 'P003';
-- Mong doi: type = const, key = idx_productCode, rows = 1

EXPLAIN SELECT * FROM Products
WHERE productName = 'Laptop Dell XPS' AND productPrice = 1500.00;
-- Mong doi: type = ref, key = idx_productName_price, rows = 1
-- (Bang rat nho nen optimizer doi khi van chon quet toan bang; neu vay
--  hay them nhieu dong du lieu de thay ro su khac biet.)

-- Index kep chi huu ich khi dieu kien bat dau tu cot ben trai (productName)
EXPLAIN SELECT * FROM Products WHERE productName = 'Laptop Dell XPS';
EXPLAIN SELECT * FROM Products WHERE productPrice = 1500.00;
-- Cau thu hai khong bat dau tu productName nen khong tan dung duoc index kep

-- Unique index con chan trung ma san pham (bo comment de thu, se bao loi):
-- INSERT INTO Products (productCode, productName, productPrice, productAmount)
-- VALUES ('P001', 'San pham trung ma', 10.00, 1);

/* =====================================================
   BUOC 4: View
   ===================================================== */

-- 4.1 Tao view
CREATE VIEW product_views AS
SELECT productCode, productName, productPrice, productStatus
FROM Products;

SELECT * FROM product_views;

-- 4.2 Sua doi view (them cot productAmount, chi lay san pham con hang)
CREATE OR REPLACE VIEW product_views AS
SELECT productCode, productName, productPrice, productAmount, productStatus
FROM Products
WHERE productStatus = 'Available';

SELECT * FROM product_views;   -- Mong doi: 8 dong

-- 4.3 Xoa view
DROP VIEW product_views;

/* =====================================================
   BUOC 5: Stored procedure
   ===================================================== */

-- 5.1 Lay tat ca san pham
DELIMITER //
DROP PROCEDURE IF EXISTS getAllProducts//
CREATE PROCEDURE getAllProducts()
BEGIN
    SELECT * FROM Products;
END //
DELIMITER ;

-- 5.2 Them san pham moi
DELIMITER //
DROP PROCEDURE IF EXISTS addProduct//
CREATE PROCEDURE addProduct(
    IN p_code        VARCHAR(20),
    IN p_name        VARCHAR(100),
    IN p_price       DECIMAL(12,2),
    IN p_amount      INT,
    IN p_description VARCHAR(255),
    IN p_status      VARCHAR(20)
)
BEGIN
    INSERT INTO Products
        (productCode, productName, productPrice, productAmount, productDescription, productStatus)
    VALUES
        (p_code, p_name, p_price, p_amount, p_description, p_status);
END //
DELIMITER ;

-- 5.3 Sua san pham theo id
DELIMITER //
DROP PROCEDURE IF EXISTS editProductById//
CREATE PROCEDURE editProductById(
    IN p_id          INT,
    IN p_code        VARCHAR(20),
    IN p_name        VARCHAR(100),
    IN p_price       DECIMAL(12,2),
    IN p_amount      INT,
    IN p_description VARCHAR(255),
    IN p_status      VARCHAR(20)
)
BEGIN
    UPDATE Products
    SET productCode        = p_code,
        productName        = p_name,
        productPrice       = p_price,
        productAmount      = p_amount,
        productDescription = p_description,
        productStatus      = p_status
    WHERE Id = p_id;
END //
DELIMITER ;

-- 5.4 Xoa san pham theo id
DELIMITER //
DROP PROCEDURE IF EXISTS deleteProductById//
CREATE PROCEDURE deleteProductById(IN p_id INT)
BEGIN
    DELETE FROM Products WHERE Id = p_id;
END //
DELIMITER ;

/* =====================================================
   Chay thu cac stored procedure
   ===================================================== */

CALL getAllProducts();

CALL addProduct('P011', 'Webcam Logitech', 75.00, 60, 'Webcam Full HD', 'Available');
CALL getAllProducts();          -- co them P011

CALL editProductById(11, 'P011', 'Webcam Logitech C920', 80.00, 55, 'Webcam Full HD 1080p', 'Available');
SELECT * FROM Products WHERE Id = 11;   -- da doi ten va gia

CALL deleteProductById(11);
CALL getAllProducts();          -- P011 da bi xoa

SHOW PROCEDURE STATUS WHERE Db = 'demo';
