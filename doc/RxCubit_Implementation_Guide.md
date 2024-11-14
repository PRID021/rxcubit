# Tài Liệu và Giải Thích về `RxCubit`

## 1. Mục Tiêu

### Phát triển một package Flutter cho việc quản lý state **mà không sử dụng bất kỳ package quản lý state nào có sẵn** trên pub.dev. Package cần:

- Hỗ trợ quản lý state hiệu quả và dễ tích hợp vào các ứng dụng Flutter.
- Tối ưu hiệu suất bằng cách chỉ cập nhật các thành phần UI khi cần thiết để tránh render không cần thiết.
- Cung cấp API thân thiện với lập trình viên để tích hợp dễ dàng và trực quan.

## 2. Yêu Cầu và Mục Tiêu Thiết Kế

### Yêu Cầu Thiết Kế:

- **Kiến trúc rõ ràng và dễ mở rộng** để hỗ trợ tích hợp vào các ứng dụng với quy mô từ đơn giản đến phức tạp.
- Hỗ trợ cả **state đơn giản** (biến đơn lẻ) và **state phức tạp** (mảng, map hoặc cấu trúc nested).

### Yêu Cầu Chức Năng:

- Cung cấp các phương thức:
  - Khởi tạo state với giá trị mặc định.
  - Cập nhật, thay đổi và theo dõi các state.
  - Reset hoặc xóa state khi cần thiết.
- Đảm bảo rằng các thành phần UI **chỉ được render lại khi state có thay đổi** để tối ưu hiệu suất.
- Hỗ trợ cả **cập nhật state đồng bộ và bất đồng bộ**.

---

## 3. Giới Thiệu về `RxCubit`

### a. Tổng Quan:

`RxCubit` là một lớp quản lý state lấy cảm hứng từ `Cubit` pattern sử dụng `BehaviorSubject` từ package `rxdart` để quản lý state một cách hiệu quả. Thay vì phụ thuộc vào các package quản lý state phức tạp, `RxCubit` sử dụng stream (`BehaviorSubject`) để theo dõi và phát tán các thay đổi của state, giúp tối ưu hóa việc cập nhật UI.

### b. Tại Sao `RxCubit` Hiệu Quả và Tối Ưu:

- Sử dụng **RxDart** giúp tích hợp dễ dàng với các thao tác bất đồng bộ.
- `BehaviorSubject` giữ lại giá trị cuối cùng đã phát tán và phát lại nó cho các subscriber mới, điều này rất hữu ích khi các widget cần lấy giá trị state ngay khi khởi tạo.
- Việc sử dụng **`distinct()`** giúp đảm bảo chỉ cập nhật khi có sự thay đổi thực sự của state, giảm thiểu việc render không cần thiết.
- Phương thức **`select()`** cho phép chỉ nghe những phần cụ thể của state, điều này giúp tránh việc lắng nghe quá mức và tối ưu hóa tài nguyên.

---

## 4. Giải Thích Về Cách Triển Khai `RxCubit`

Cùng phân tích mã nguồn:

### a. Khởi Tạo Cubit

```dart
RxCubit(State initialState)
    : _initialState = initialState,
      _controller = BehaviorSubject<State>.seeded(initialState) {
  observer?.onCubitInit(this);
}
```

**Giải Thích**:

- Khi khởi tạo `RxCubit`, `BehaviorSubject` được khởi tạo với giá trị state ban đầu.
- `observer` tùy chọn có thể được sử dụng để theo dõi khi một cubit được tạo ra (hữu ích cho việc gỡ lỗi hoặc thống kê).

### b. Truy Cập Stream và State Hiện Tại

```dart
Stream<State> get stream =>
    _controller.stream.doOnListen(_onListen).doOnCancel(_onCancel);
State get state => _controller.value;
```

**Giải Thích**:

- `stream`: Trả về stream của state với các hook để theo dõi số lượng listener bằng `doOnListen` và `doOnCancel`.
- `state`: Trả về giá trị state hiện tại.

### c. Phát Tán Thay Đổi State

```dart
void emit(State newState) {
  if (!_controller.isClosed && state != newState) {
    observer?.onStateChanged(this, state, newState);
    _controller.add(newState);
  }
}
```

**Giải Thích**:

- Phương thức `emit()` chỉ phát tán trạng thái mới nếu trạng thái đó khác với trạng thái hiện tại. Điều này ngăn chặn việc phát tán trạng thái không cần thiết và giảm thiểu việc render lại không cần thiết.

### d. Reset về State Ban Đầu

```dart
void reset() {
  if (!_controller.isClosed && state != _initialState) {
    observer?.onStateChanged(this, state, _initialState);
    _controller.add(_initialState);
  }
}
```

**Giải Thích**:

- Phương thức `reset()` giúp đưa state trở lại giá trị ban đầu. Điều này hữu ích khi cần xóa hoặc làm mới state.

### e. Chọn Các Thuộc Tính Cụ Thể Của State

```dart
Stream<T> select<T>(T Function(State state) selector) {
  return stream.map(selector).distinct().skip(1);
}
```

**Giải Thích**:

- Phương thức `select()` cho phép lắng nghe những phần cụ thể của state. Nó sử dụng `distinct()` để loại bỏ các thay đổi không cần thiết và bỏ qua giá trị đầu tiên khi widget được khởi tạo.

### f. Tự Động Đóng Stream

```dart
void _onListen() {
  _activeListeners++;
}

void _onCancel() {
  _activeListeners--;
  if (_activeListeners <= 0) {
    close();
  }
}
```

**Giải Thích**:

- Theo dõi số lượng listeners đang hoạt động. Khi không còn listener nào, cubit sẽ tự động đóng để giải phóng tài nguyên, ngăn ngừa rò rỉ bộ nhớ.

---

## 5. Lợi Ích Của Việc Sử Dụng `RxCubit`

- **Hiệu suất cao**: Bằng cách tránh cập nhật trạng thái không cần thiết, nó giúp giảm thiểu việc render lại UI.
- **Dễ sử dụng và mở rộng**: API rõ ràng giúp dễ dàng tích hợp vào các dự án hiện tại mà không cần thay đổi cấu trúc ứng dụng nhiều.
- **Tích hợp mượt mà**: Hỗ trợ cả cập nhật state đồng bộ và bất đồng bộ, rất cần thiết cho các tác vụ phức tạp hoặc khi gọi API.

---

## 6. Kết Luận

Với `RxCubit`, bạn đã xây dựng thành công một giải pháp quản lý state hiệu quả và dễ dàng, không phụ thuộc vào các package bên ngoài. Bằng cách sử dụng `RxDart`, bạn có thể quản lý state một cách hiệu quả qua streams, selectors và lọc state hợp lý. Giải pháp này giúp các ứng dụng Flutter duy trì hiệu suất và phản hồi tốt.

---

## 7. Ví Dụ Sử Dụng

Dưới đây là ví dụ đơn giản về cách sử dụng `RxCubit` trong một ứng dụng Flutter:

```dart
final counterCubit = RxCubit<int>(0);

// Lắng nghe thay đổi state
counterCubit.stream.listen((count) {
  print('Số đếm đã thay đổi: $count');
});

// Phát tán các trạng thái mới
counterCubit.emit(1);
counterCubit.emit(2);

// Reset về giá trị ban đầu
counterCubit.reset();

// Đóng cubit khi không còn sử dụng
counterCubit.close();
```

Trong ví dụ này:

- Một `counterCubit` được tạo với giá trị ban đầu là `0`.
- Stream lắng nghe các thay đổi và in ra giá trị đếm mới.
- Các trạng thái mới được phát tán và theo dõi theo thời gian thực.
- State có thể được reset về giá trị ban đầu.
- Cubit được đóng khi không còn cần thiết để tránh rò rỉ bộ nhớ.

---
