/*
  Bai tap: Luyen tap tao stored procedure tren CSDL classicmodels
  Luu y: chay file nay SAU KHI da tao database va chen du lieu.
*/

USE classicmodels;

/* =====================================================
   PHAN 1: Stored procedure co ban
   ===================================================== */

-- 1.1 findAllCustomers(): lay tat ca khach hang
DELIMITER //
DROP PROCEDURE IF EXISTS findAllCustomers//
CREATE PROCEDURE findAllCustomers()
BEGIN
  SELECT * FROM customers;
END //
DELIMITER ;

CALL findAllCustomers();

-- 1.2 Sua procedure: MySQL phai DROP roi CREATE lai
DELIMITER //
DROP PROCEDURE IF EXISTS findAllCustomers//
CREATE PROCEDURE findAllCustomers()
BEGIN
  SELECT * FROM customers WHERE customerNumber = 175;
END //
DELIMITER ;

CALL findAllCustomers();

/* =====================================================
   PHAN 2: Tham so loai IN
   ===================================================== */

DELIMITER //
DROP PROCEDURE IF EXISTS getCusById//
CREATE PROCEDURE getCusById(IN cusNum INT(11))
BEGIN
  SELECT * FROM customers WHERE customerNumber = cusNum;
END //
DELIMITER ;

CALL getCusById(175);

/* =====================================================
   PHAN 3: Tham so loai OUT
   ===================================================== */

DELIMITER //
DROP PROCEDURE IF EXISTS GetCustomersCountByCity//
CREATE PROCEDURE GetCustomersCountByCity(
    IN  in_city VARCHAR(50),
    OUT total   INT
)
BEGIN
    SELECT COUNT(customerNumber)
    INTO total
    FROM customers
    WHERE city = in_city;
END //
DELIMITER ;

CALL GetCustomersCountByCity('Lyon', @total);
SELECT @total;   -- Ket qua mong doi: 1

/* =====================================================
   PHAN 4: Tham so loai INOUT
   ===================================================== */

DELIMITER //
DROP PROCEDURE IF EXISTS SetCounter//
CREATE PROCEDURE SetCounter(
    INOUT counter INT,
    IN    inc     INT
)
BEGIN
    SET counter = counter + inc;
END //
DELIMITER ;

SET @counter = 1;
CALL SetCounter(@counter, 1);  -- 2
CALL SetCounter(@counter, 1);  -- 3
CALL SetCounter(@counter, 5);  -- 8
SELECT @counter;               -- 8

/* =====================================================
   PHAN 5: Thuc hanh them cac stored procedure khac
   ===================================================== */

-- 5.1 (IN) Lay khach hang theo quoc gia
DELIMITER //
DROP PROCEDURE IF EXISTS getCustomersByCountry//
CREATE PROCEDURE getCustomersByCountry(IN in_country VARCHAR(50))
BEGIN
    SELECT customerNumber, customerName, city, country, creditLimit
    FROM customers
    WHERE country = in_country;
END //
DELIMITER ;

CALL getCustomersByCountry('France');

-- 5.2 (IN + OUT) Tong so tien khach hang da thanh toan
DELIMITER //
DROP PROCEDURE IF EXISTS getTotalPaymentsByCustomer//
CREATE PROCEDURE getTotalPaymentsByCustomer(
    IN  cusNum    INT,
    OUT totalPaid DECIMAL(12,2)
)
BEGIN
    SELECT IFNULL(SUM(amount), 0)
    INTO totalPaid
    FROM payments
    WHERE customerNumber = cusNum;
END //
DELIMITER ;

CALL getTotalPaymentsByCustomer(175, @paid);
SELECT @paid;    -- Ket qua mong doi: 95424.63

-- 5.3 (IN + OUT) Dem so don hang theo trang thai
DELIMITER //
DROP PROCEDURE IF EXISTS getOrderCountByStatus//
CREATE PROCEDURE getOrderCountByStatus(
    IN  in_status VARCHAR(15),
    OUT total     INT
)
BEGIN
    SELECT COUNT(orderNumber)
    INTO total
    FROM orders
    WHERE status = in_status;
END //
DELIMITER ;

CALL getOrderCountByStatus('Cancelled', @cancelled);
SELECT @cancelled;   -- Ket qua mong doi: 6

-- 5.4 (INOUT + IN) Giam gia: gia tri duoc cap nhat truc tiep vao bien truyen vao
DELIMITER //
DROP PROCEDURE IF EXISTS applyDiscount//
CREATE PROCEDURE applyDiscount(
    INOUT price   DECIMAL(10,2),
    IN    percent INT
)
BEGIN
    SET price = price * (100 - percent) / 100;
END //
DELIMITER ;

SET @price = 200.00;
CALL applyDiscount(@price, 10);
SELECT @price;       -- Ket qua mong doi: 180.00

/* =====================================================
   Kiem tra cac procedure da tao
   ===================================================== */
SHOW PROCEDURE STATUS WHERE Db = 'classicmodels';
