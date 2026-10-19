# Nhật ký tra cứu AI – Bài SmartFactory

> Đây là **mẫu**. Hãy dán prompt bạn thực sự đã hỏi và tóm tắt câu trả lời bằng lời của bạn. Mục "Điều mình rút ra" là phần quan trọng nhất.

## 1. Covering Index

**Prompt gợi ý:**
"Covering Index trong MySQL là gì? Vì sao nó làm SELECT nhanh hơn, và dấu hiệu `Using index` trong EXPLAIN nghĩa là gì?"

**Tóm tắt câu trả lời của AI:** [điền]

**Điều mình rút ra:** [điền]

## 2. Clustered Index và Secondary Index trong InnoDB

**Prompt gợi ý:**
"InnoDB lưu dữ liệu ở clustered index (khóa chính) và secondary index như thế nào? Vì sao mỗi entry của secondary index lại chứa thêm giá trị khóa chính?"

**Tóm tắt câu trả lời của AI:** [điền]

**Điều mình rút ra:** [điền]

## 3. Write Penalty

**Prompt gợi ý:**
"Khi INSERT vào bảng InnoDB có nhiều secondary index thì điều gì xảy ra ở tầng page, buffer pool, change buffer và redo log? Thêm một cột vào index làm INSERT chậm hơn vì sao?"

**Tóm tắt câu trả lời của AI:** [điền]

**Điều mình rút ra:** [điền]

## 4. Tính dung lượng theo kiểu dữ liệu (để lấy điểm tối đa)

**Prompt gợi ý:**
"Hãy cho tôi biết dung lượng (byte) của INT, BIGINT, DATETIME, DECIMAL(5,2), VARCHAR(20) với utf8mb4 trong InnoDB, và giúp tôi ước tính kích thước một entry của index `(sensor_id, recorded_at, temperature, humidity, status)` so với `(sensor_id, recorded_at)`."

**Tóm tắt câu trả lời của AI:** [điền]

**Điều mình rút ra / bảng tính của mình:** [điền]

## 5. Đổi VARCHAR(20) sang TINYINT

**Prompt gợi ý:**
"Nếu đổi cột `status` từ VARCHAR(20) sang TINYINT thì Data_length và Index_length thay đổi thế nào, trong trường hợp cột đó nằm trong index và không nằm trong index?"

**Tóm tắt câu trả lời của AI:** [điền]

**Điều mình rút ra:** [điền]
