USE classicmodels;

-- ===== 1. Tạo stored procedure findAllCustomers() =====
DELIMITER //
DROP PROCEDURE IF EXISTS findAllCustomers//
CREATE PROCEDURE findAllCustomers()
BEGIN
  SELECT * FROM customers;
END //
DELIMITER ;

CALL findAllCustomers();

-- ===== 2. Sửa procedure (MySQL phải DROP rồi CREATE lại) =====
DELIMITER //
DROP PROCEDURE IF EXISTS findAllCustomers//
CREATE PROCEDURE findAllCustomers()
BEGIN
  SELECT * FROM customers WHERE customerNumber = 175;
END //
DELIMITER ;

CALL findAllCustomers();

-- ===== 3. Procedure có tham số IN =====
DELIMITER //
DROP PROCEDURE IF EXISTS getCustomerById//
CREATE PROCEDURE getCustomerById(IN cusNum INT)
BEGIN
  SELECT * FROM customers WHERE customerNumber = cusNum;
END //
DELIMITER ;

CALL getCustomerById(175);

-- ===== 4. Procedure có tham số OUT =====
DELIMITER //
DROP PROCEDURE IF EXISTS getCustomersCountByCity//
CREATE PROCEDURE getCustomersCountByCity(
  IN  in_city VARCHAR(50),
  OUT total   INT
)
BEGIN
  SELECT COUNT(customerNumber) INTO total
  FROM customers
  WHERE city = in_city;
END //
DELIMITER ;

CALL getCustomersCountByCity('Lyon', @total);
SELECT @total;

-- ===== 5. Procedure có tham số INOUT =====
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
SELECT @counter;