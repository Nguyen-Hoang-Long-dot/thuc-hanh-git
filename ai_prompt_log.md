# Nhật ký tra cứu AI – Bài QuickFeed

> Đây là **mẫu**. Hãy dán prompt bạn thực sự đã hỏi và tóm tắt câu trả lời bằng lời của bạn. Mục "Điều mình rút ra" là phần quan trọng nhất.

## 1. Cardinality và Index trên cột TEXT / BOOLEAN

**Prompt:**
"Trong MySQL, nếu tôi tạo Index trên một cột chứa văn bản dài (TEXT) và một cột kiểu BOOLEAN (0 và 1), thì điều này gây hại như thế nào đến bộ nhớ RAM, dung lượng Disk và bộ tối ưu hóa (Query Optimizer)?"

**Tóm tắt câu trả lời của AI:** [điền]

**Điều mình rút ra:** [điền]

## 2. Vì sao optimizer bỏ qua index có cardinality thấp

**Prompt:**
"Tại sao khi tôi truy vấn `SELECT * FROM Posts WHERE is_visible = 1` trên bảng hàng triệu dòng (99% là visible = 1), MySQL lại quét toàn bảng thay vì dùng `idx_is_visible`?"

**Tóm tắt câu trả lời của AI:** [điền]

**Điều mình rút ra:** [điền]

## 3. Xem dung lượng Data và Index

**Prompt:**
"Hãy cho tôi xem truy vấn SQL sử dụng bảng `information_schema.TABLES` để in ra kích thước Data và kích thước Index của bảng `Posts` theo MB."

**Tóm tắt câu trả lời của AI:** [điền]

**Điều mình rút ra:** [điền]

## 4. Tìm kiếm từ khóa trong cột TEXT

**Prompt:**
"Nếu muốn tìm kiếm từ khóa trong cột `content` (kiểu TEXT) mà không tốn nhiều dung lượng như B-Tree Index, tôi nên dùng cơ chế nào của MySQL?"

**Tóm tắt câu trả lời của AI:** [điền]

**Điều mình rút ra:** [điền]

## 5. (Để lấy điểm tối đa) Data Pages và Index Pages trong InnoDB

**Prompt gợi ý:**
"InnoDB lưu clustered index và secondary index trong các page như thế nào? Khi INSERT vào bảng có nhiều secondary index thì điều gì xảy ra ở tầng page, buffer pool và redo log?"

**Tóm tắt câu trả lời của AI:** [điền]

**Điều mình rút ra:** [điền]
