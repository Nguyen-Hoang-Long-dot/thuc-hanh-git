# Báo cáo tối ưu Index – QuickFeed (bảng `Posts`)

## Số liệu đo được

Điền số liệu từ lần chạy thực tế của `quickfeed_index_optimization.sql` (cột `data_mb`, `index_mb`, `insert_20k_ms_*`).

| Chỉ số | Trước (5 index) | Sau (2 index) | Thay đổi |
|---|---|---|---|
| Data (MB) | [điền] | [điền] | [điền] |
| Index (MB) | [điền] | [điền] | [điền] |
| Index / Data | [điền] | [điền] | [điền] |
| INSERT 20.000 dòng (ms) | [điền] | [điền] | [điền] |

## Phân tích

Mỗi lần INSERT, InnoDB phải ghi dòng dữ liệu vào clustered index (khóa chính), rồi cập nhật thêm một cây B-Tree cho từng secondary index. Với 5 index, một lệnh INSERT kéo theo 5 lần cập nhật cây phụ, kèm ghi redo log và có thể tách page. Đó là nguyên nhân gây timeout khi đăng bài. Index dư thừa cũng chiếm RAM trong buffer pool, đẩy dữ liệu "nóng" ra khỏi bộ nhớ.

Ba index bị loại bỏ đều kém hiệu quả:
- `idx_content`: cột TEXT dài, cây B-Tree rất lớn và không phục vụ tìm kiếm từ khóa. Nên dùng FULLTEXT nếu cần.
- `idx_post_type` (cardinality 3) và `idx_is_visible` (cardinality 2): mỗi giá trị khớp với một phần rất lớn của bảng, nên optimizer thường chọn quét toàn bảng.

Hai index được giữ lại là `idx_user_id` (tải trang cá nhân) và `idx_created_at` (sắp xếp newsfeed).

## Kết luận về Read/Write

Index đánh đổi tốc độ ghi và dung lượng để lấy tốc độ đọc. Chỉ nên giữ index có tính phân biệt cao và thật sự được truy vấn. Sau khi bỏ 3 index, mỗi INSERT giảm từ 5 xuống 2 lần cập nhật cây B-Tree phụ, tức bớt 3 lần.
