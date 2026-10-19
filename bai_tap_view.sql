/*
  Bai tap: Tao view tren CSDL classicmodels
  Luu y: chay file nay SAU KHI da tao database va chen du lieu.
*/

USE classicmodels;

/* =====================================================
   PHAN 1: Tao view customer_views
   ===================================================== */

CREATE VIEW customer_views AS
SELECT customerNumber, customerName, phone
FROM customers;

SELECT * FROM customer_views;   -- Ket qua mong doi: 122 dong, 3 cot

/* =====================================================
   PHAN 2: Cap nhat view
   (View chi tu 1 bang, khong co DISTINCT/GROUP BY/...
   nen co the cap nhat bang CREATE OR REPLACE VIEW)
   ===================================================== */

CREATE OR REPLACE VIEW customer_views AS
SELECT customerNumber, customerName, contactFirstName, contactLastName, phone
FROM customers
WHERE city = 'Nantes';

SELECT * FROM customer_views;   -- Ket qua mong doi: 2 dong (103 va 119)

/* =====================================================
   PHAN 3: Xoa view
   ===================================================== */

DROP VIEW customer_views;

/* =====================================================
   PHAN 4: Thuc hanh them cac view khac
   ===================================================== */

-- 4.1 View khach hang o USA (1 bang, co the cap nhat duoc)
CREATE OR REPLACE VIEW usa_customers AS
SELECT customerNumber, customerName, city, state, phone, creditLimit
FROM customers
WHERE country = 'USA';

SELECT * FROM usa_customers;

-- 4.2 View ket hop nhieu bang (JOIN): khach hang va nhan vien phu trach
--     Vi dinh nghia tu 2 bang nen view nay KHONG cap nhat duoc
CREATE OR REPLACE VIEW customer_sales_rep AS
SELECT c.customerNumber,
       c.customerName,
       CONCAT(e.firstName, ' ', e.lastName) AS salesRepName,
       e.email AS salesRepEmail
FROM customers c
JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber;

SELECT * FROM customer_sales_rep;

-- 4.3 View tong hop (GROUP BY + ham gop): tong thanh toan cua tung khach hang
--     View nay cung KHONG cap nhat duoc
CREATE OR REPLACE VIEW customer_payment_totals AS
SELECT c.customerNumber,
       c.customerName,
       SUM(p.amount) AS totalPaid
FROM customers c
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerNumber, c.customerName;

SELECT * FROM customer_payment_totals ORDER BY totalPaid DESC;

/* =====================================================
   Kiem tra cac view da tao
   ===================================================== */
SHOW FULL TABLES IN classicmodels WHERE Table_type = 'VIEW';
