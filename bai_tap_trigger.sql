/*
  Bai tap: Su dung Trigger trong MySQL
  Bai nay dung CSDL rieng ten "company", khong lien quan classicmodels.
  Yeu cau: MySQL 5.7.2 tro len (dung PRECEDES o phan 5).
*/

/* =====================================================
   BUOC 1: Tao CSDL va bang
   ===================================================== */

CREATE DATABASE IF NOT EXISTS company;

USE company;

DROP TABLE IF EXISTS employee_log;
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(50)   NOT NULL,
    department VARCHAR(50)   NOT NULL,
    salary     DECIMAL(10,2) NOT NULL
);

/* =====================================================
   BUOC 2: Tao trigger update_department
   Truoc khi INSERT, tu dong gan phong ban theo muc luong
   ===================================================== */

DELIMITER //

CREATE TRIGGER update_department
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary >= 5000 THEN
        SET NEW.department = 'Management';
    ELSEIF NEW.salary >= 3000 THEN
        SET NEW.department = 'Sales';
    ELSE
        SET NEW.department = 'Support';
    END IF;
END //

DELIMITER ;

/* =====================================================
   BUOC 3: Demo su dung trigger
   Du lieu nhap phong ban 'A' nhung trigger se ghi de lai
   ===================================================== */

INSERT INTO employees (name, department, salary)
VALUES ('John Doe',      'A', 3500),
       ('Jane Smith',    'A', 2000),
       ('David Johnson', 'A', 6000);

SELECT * FROM employees;
-- Ket qua mong doi:
--   John Doe      -> Sales       (3500)
--   Jane Smith    -> Support     (2000)
--   David Johnson -> Management  (6000)

/* =====================================================
   BUOC 4: Thuc hanh them - trigger BEFORE UPDATE
   Khi luong thay doi, phong ban tu dong cap nhat theo
   ===================================================== */

DELIMITER //

CREATE TRIGGER update_department_on_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary >= 5000 THEN
        SET NEW.department = 'Management';
    ELSEIF NEW.salary >= 3000 THEN
        SET NEW.department = 'Sales';
    ELSE
        SET NEW.department = 'Support';
    END IF;
END //

DELIMITER ;

/* =====================================================
   BUOC 5: Thuc hanh them - trigger kiem tra du lieu
   Khong cho phep luong am (dung SIGNAL de bao loi)
   PRECEDES: chay truoc trigger gan phong ban
   ===================================================== */

DELIMITER //

CREATE TRIGGER check_salary_insert
BEFORE INSERT ON employees
FOR EACH ROW
PRECEDES update_department
BEGIN
    IF NEW.salary < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Luong khong duoc am';
    END IF;
END //

CREATE TRIGGER check_salary_update
BEFORE UPDATE ON employees
FOR EACH ROW
PRECEDES update_department_on_update
BEGIN
    IF NEW.salary < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Luong khong duoc am';
    END IF;
END //

DELIMITER ;

-- Thu them nhan vien luong am se bi bao loi (bo comment de thu,
-- lenh nay se dung script nen de o dang comment):
-- INSERT INTO employees (name, department, salary) VALUES ('Test', 'A', -100);

/* =====================================================
   BUOC 6: Thuc hanh them - trigger ghi log (AFTER)
   ===================================================== */

CREATE TABLE employee_log (
    log_id      INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT           NOT NULL,
    action      VARCHAR(10)   NOT NULL,
    old_salary  DECIMAL(10,2) DEFAULT NULL,
    new_salary  DECIMAL(10,2) DEFAULT NULL,
    changed_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER log_employee_insert
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_log (employee_id, action, old_salary, new_salary)
    VALUES (NEW.id, 'INSERT', NULL, NEW.salary);
END //

CREATE TRIGGER log_employee_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO employee_log (employee_id, action, old_salary, new_salary)
        VALUES (NEW.id, 'UPDATE', OLD.salary, NEW.salary);
    END IF;
END //

DELIMITER ;

/* =====================================================
   BUOC 7: Demo cac trigger vua tao
   ===================================================== */

INSERT INTO employees (name, department, salary)
VALUES ('Alice Brown', 'A', 4500);          -- -> Sales

UPDATE employees SET salary = 5200 WHERE name = 'Jane Smith';   -- -> Management

SELECT * FROM employees;
SELECT * FROM employee_log;
-- employee_log co 2 dong: INSERT cua Alice Brown, UPDATE luong cua Jane Smith (2000 -> 5200)

/* =====================================================
   Kiem tra cac trigger da tao
   ===================================================== */
SHOW TRIGGERS;
