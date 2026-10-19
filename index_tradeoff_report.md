# Báo cáo đánh đổi Index – SmartFactory (bảng `SensorLogs`)

## Số liệu đo được

Điền từ lần chạy thực tế của `smartfactory_reindex.sql`.

| Chỉ số | Fat Index (5 cột) | Lean Index (2 cột) | Thay đổi |
|---|---|---|---|
| Index_length (MB) | [điền] | [điền] | [điền] |
| INSERT 20.000 dòng (ms) | [điền] | [điền] | [điền] |
| EXPLAIN: `key` | idx_fat_covering | idx_lean_search | |
| EXPLAIN: `type` | [điền] | [điền] | |
| EXPLAIN: `Extra` | Using index | [điền] | |

## Ước tính dung lượng mỗi entry của index phụ

Mỗi entry của index phụ chứa các cột của index cộng với khóa chính (`log_id`, BIGINT = 8 byte).

- Fat Index: `sensor_id` 4 + `recorded_at` 5 + `temperature` 3 + `humidity` 3 + `status` khoảng 7 (1 byte độ dài + khoảng 6 ký tự) + khóa chính 8 = khoảng **30 byte** (chưa tính phần header của bản ghi).
- Lean Index: 4 + 5 + 8 = **17 byte**.

Mức giảm lý thuyết khoảng 40%. Con số đo thực tế có thể khác do header, độ lấp đầy page và lần chạy cụ thể.

## Giải trình

Covering Index giúp Dashboard đọc thẳng từ index, nhưng với cảm biến ghi hàng chục nghìn bản ghi mỗi giây, mỗi INSERT phải chèn một entry dài vào cây B-Tree, gây tách page và ghi redo log nhiều hơn (Write Penalty). Index cũng chiếm RAM trong buffer pool và dung lượng SSD trả tiền hằng tháng.

Lean Index `(sensor_id, recorded_at)` vẫn phục vụ đủ điều kiện lọc của Dashboard (`type` vẫn là range). Cái giá phải trả là mỗi dòng kết quả cần thêm một lần lookup vào bảng gốc để lấy `temperature`, `humidity`, `status`, nên SELECT chậm đi một chút. Đổi lại, luồng ghi nhanh hơn, pipeline không còn mất dữ liệu và chi phí lưu trữ giảm.
