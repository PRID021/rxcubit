
# Tài liệu lớp `StateObserver`

Lớp `StateObserver` được thiết kế để theo dõi vòng đời và thay đổi trạng thái của các đối tượng `RxCubit`. Nó cung cấp các phương thức để xử lý các sự kiện như thay đổi trạng thái, lỗi, khởi tạo và hủy bỏ cubit. Lớp này rất hữu ích trong việc gỡ lỗi và ghi lại thông tin trong quá trình phát triển.

### Các phương thức chính:

#### `onStateChanged<C extends RxCubit>(C cubit, dynamic previousState, dynamic newState)`

- **Mục đích**: Được gọi khi trạng thái của một cubit thay đổi.
- **Tham số**:
  - `cubit`: Đối tượng `RxCubit` có trạng thái đã thay đổi.
  - `previousState`: Trạng thái trước khi thay đổi.
  - `newState`: Trạng thái mới sau khi thay đổi.
- **Chức năng**: Ghi lại sự thay đổi trạng thái trong chế độ gỡ lỗi với giá trị trạng thái trước và sau.
- **Sử dụng**: Phương thức này thường được gọi sau khi thay đổi trạng thái trong cubit để cung cấp thông tin về sự chuyển trạng thái.

#### `onError<C extends RxCubit>(C cubit, Object error, StackTrace stackTrace)`

- **Mục đích**: Được gọi khi có lỗi xảy ra trong cubit.
- **Tham số**:
  - `cubit`: Đối tượng `RxCubit` nơi lỗi xảy ra.
  - `error`: Lỗi xảy ra.
  - `stackTrace`: Trace ngăn xếp liên quan đến lỗi.
- **Chức năng**: Ghi lại lỗi và trace ngăn xếp trong chế độ gỡ lỗi để dễ dàng theo dõi.
- **Sử dụng**: Phương thức này giúp ghi lại và theo dõi lỗi trong cubit để dễ dàng gỡ lỗi.

#### `onCubitInit<C extends RxCubit>(C cubit)`

- **Mục đích**: Được gọi khi một cubit được khởi tạo.
- **Tham số**:
  - `cubit`: Đối tượng `RxCubit` đang được khởi tạo.
- **Chức năng**: Ghi lại việc khởi tạo cubit trong chế độ gỡ lỗi.
- **Sử dụng**: Phương thức này rất hữu ích trong việc gỡ lỗi và xác nhận quá trình khởi tạo của các đối tượng cubit.

#### `onCubitDispose<C extends RxCubit>(C cubit)`

- **Mục đích**: Được gọi khi một cubit bị hủy bỏ.
- **Tham số**:
  - `cubit`: Đối tượng `RxCubit` đang bị hủy bỏ.
- **Chức năng**: Ghi lại việc hủy bỏ cubit trong chế độ gỡ lỗi.
- **Sử dụng**: Phương thức này giúp xác nhận và ghi lại sự hủy bỏ của các đối tượng cubit trong quá trình phát triển.
