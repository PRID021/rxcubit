# Tài Liệu Thiết kế `RxCubit`

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

`RxCubit` lấy cảm hứng từ `Cubit` pattern sử dụng `BehaviorSubject` từ package `rxdart` để quản lý state một cách hiệu quả. Thay vì phụ thuộc vào các package quản lý state phức tạp, `RxCubit` sử dụng stream (`BehaviorSubject`) để theo dõi và phát tán các thay đổi của state, giúp tối ưu hóa việc cập nhật UI.

### b. Tại Sao `RxCubit` Hiệu Quả và Tối Ưu:

- Sử dụng **RxDart** giúp tích hợp dễ dàng với các thao tác bất đồng bộ.
- `BehaviorSubject` giữ lại giá trị cuối cùng đã phát tán và phát lại nó cho các subscriber mới, điều này rất hữu ích khi các widget cần lấy giá trị state ngay khi khởi tạo.
- Việc sử dụng **`distinct()`** giúp đảm bảo chỉ cập nhật khi có sự thay đổi thực sự của state, giảm thiểu việc render không cần thiết.
- Phương thức **`select()`** cho phép chỉ nghe những phần cụ thể của state, điều này giúp tránh việc lắng nghe quá mức và tối ưu hóa tài nguyên.

### c. Pattern của RxCubit

![RxCubit Pattern](https://i0.wp.com/resocoder.com/wp-content/uploads/2020/07/cubit_architecture_full.png?w=800&ssl=1)

UI component sẽ truy xuất trực tiếp function của cubit thay vì tạo ra các `event` như bloc pattern, điều này giúp đơn giản hóa việc triển khai và đảm bảo hiệu xuất của ứng dụng, `state` sẽ được `emit` từ cubit, UI sẽ lắng nghe state và cập nhật trạng thái phù hợp.

## 4. Cách Triển Khai `RxCubit`

### a. Khởi Tạo Cubit

```dart
RxCubit(State initialState)
    : _initialState = initialState,
      _controller = BehaviorSubject<State>.seeded(initialState) {
  observer?.onCubitInit(this);
}
```

- Khi khởi tạo `RxCubit`, `BehaviorSubject` được khởi tạo với giá trị state ban đầu.
- `observer` tùy chọn có thể được sử dụng để theo dõi khi một cubit được tạo ra (hữu ích cho việc gỡ lỗi hoặc thống kê).

### b. Truy Cập Stream và State Hiện Tại

```dart
Stream<State> get stream =>
    _controller.stream.doOnListen(_onListen).doOnCancel(_onCancel);
State get state => _controller.value;
```

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

- Phương thức `reset()` giúp đưa state trở lại giá trị ban đầu. Điều này hữu ích khi cần xóa hoặc làm mới state.

### e. Chọn Các Thuộc Tính Cụ Thể Của State

```dart
Stream<T> select<T>(T Function(State state) selector) {
  return stream.map(selector).distinct().skip(1);
}
```

- Phương thức `select()` cho phép lắng nghe những phần cụ thể của state. Nó sử dụng `distinct()` để loại bỏ các thay đổi không cần thiết.

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

- Theo dõi số lượng listeners đang hoạt động. Khi không còn listener nào, cubit sẽ tự động đóng để giải phóng tài nguyên, ngăn ngừa rò rỉ bộ nhớ.

---

## 5. Lợi Ích Của Việc Sử Dụng `RxCubit`

- **Hiệu suất cao**: Bằng cách tránh cập nhật trạng thái không cần thiết, nó giúp giảm thiểu việc render lại UI.
- **Dễ sử dụng và mở rộng**: API rõ ràng giúp dễ dàng tích hợp vào các dự án hiện tại mà không cần thay đổi cấu trúc ứng dụng nhiều.
- **Tích hợp đơn giản**: Hỗ trợ cả cập nhật state đồng bộ và bất đồng bộ, rất cần thiết cho các tác vụ phức tạp hoặc khi gọi API.

---

## 6. Kết Luận

Với `RxCubit`, bạn đã xây dựng thành công một giải pháp quản lý state hiệu quả và dễ dàng, không phụ thuộc vào các package bên ngoài. Bằng cách sử dụng `RxDart`, bạn có thể quản lý state một cách hiệu quả qua streams, selectors và lọc state hợp lý. Giải pháp này giúp các ứng dụng Flutter duy trì hiệu suất và phản hồi tốt.

---

# `StateObserver`

`StateObserver` được thiết kế để theo dõi vòng đời và thay đổi trạng thái của các đối tượng `RxCubit`. Nó cung cấp các phương thức để xử lý các sự kiện thay đổi trạng thái, lỗi, khởi tạo và hủy bỏ cubit.

### Các phương thức chính:

#### `onStateChanged<C extends RxCubit>(C cubit, dynamic previousState, dynamic newState)`

- **Mục đích**: Được gọi khi trạng thái của một cubit thay đổi.
- **Tham số**:
  - `cubit`: Đối tượng `RxCubit` có trạng thái đã thay đổi.
  - `previousState`: Trạng thái trước khi thay đổi.
  - `newState`: Trạng thái mới sau khi thay đổi.

#### `onError<C extends RxCubit>(C cubit, Object error, StackTrace stackTrace)`

- **Mục đích**: Được gọi khi có lỗi xảy ra trong cubit.
- **Tham số**:
  - `cubit`: Đối tượng `RxCubit` nơi lỗi xảy ra.
  - `error`: Lỗi xảy ra.
  - `stackTrace`: Trace ngăn xếp liên quan đến lỗi.

#### `onCubitInit<C extends RxCubit>(C cubit)`

- **Mục đích**: Được gọi khi một cubit được khởi tạo.
- **Tham số**:
  - `cubit`: Đối tượng `RxCubit` đang được khởi tạo.

#### `onCubitDispose<C extends RxCubit>(C cubit)`

- **Mục đích**: Được gọi khi một cubit bị hủy bỏ.
- **Tham số**:
  - `cubit`: Đối tượng `RxCubit` đang bị hủy bỏ.

# `RxMessageCubit`

`RxMessageCubit` kế thừa từ `RxCubit` giúp phân chia logic emit `message` (Khi muốn hiển thị dialog thông báo lỗi) và `state` (Dùng để cập nhật UI), bằng cách tách tường minh chúng ta có dễ dàng update ui, và hiển thị dialog một cách rõ ràng.

#### `void sendMessage(M message)`

- **Mục đích**: Emit một message tới UI.
- **Tham số**:
  - `message`: một instance message dựa trên generic type.

#### Cách sử dụng

- UI component

```dart

  late CounterMessageCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = Provider.of<CounterMessageCubit>(context, listen: false);
    // Listen to messageStream for notifications
    cubit.messageStream.listen(_onMessage);
  }

  void _onMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
```

-- RxCubit

```dart

  class CounterMessageCubit extends RxMessageCubit<int, String> {
  CounterMessageCubit() : super(0);

  void increment() {
    emit(state + 1);  /// Emit state on state stream
    sendMessage('Counter incremented to $state');  /// Emit message on message stream
  }

  void decrement() {
    emit(state - 1);
    sendMessage('Counter decremented to $state');
  }
}
```

# Sử Dụng

Dưới đây là ví dụ đơn giản về cách sử dụng `RxCubit` trong một ứng dụng Flutter `main.dart`:

```dart

void main() {
  runApp(
    RxCubitScope(
      observer: MyObserver(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình mà BottomNavigationBar sẽ điều hướng tới
  final List<Widget> _pages = [
    const SingleCubitExample(),
    const MultiCubitExample(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Example'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'SSE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'MTS',
          ),
        ],
      ),
    );
  }
}

```

File `single_cubit_provider_example`.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_cubit/reactive_cubit.dart';

import 'detail_screen.dart';

class CounterState {
  final bool isLoading;
  final int count;
  final bool isEven;

  CounterState(
      {required this.isLoading, required this.count, required this.isEven});

  CounterState copyWith({int? count, bool? isEven, bool? isLoading}) {
    return CounterState(
      count: count ?? this.count,
      isEven: isEven ?? this.isEven,
      isLoading: isLoading ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterState &&
          runtimeType == other.runtimeType &&
          count == other.count &&
          isEven == other.isEven &&
          isLoading == other.isLoading;

  @override
  int get hashCode => count.hashCode ^ isEven.hashCode;
}

class CounterCubit extends RxCubit<CounterState> {
  CounterCubit()
      : super(CounterState(count: 0, isEven: true, isLoading: false));

  void increment() async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(Durations.extralong4);
    final newCount = state.count + 1;
    emit(
      state.copyWith(count: newCount, isLoading: false),
    );
  }

  void updateLabel() {
    emit(
      state.copyWith(isEven: state.count % 2 == 0),
    );
  }
}

class SingleCubitExample extends StatelessWidget {
  const SingleCubitExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => CounterCubit(),
      child: const CounterWidget(),
    );
  }
}

class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = Provider.of<CounterCubit>(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: double.infinity),
            // Only rebuilds when 'count' changes
            StreamBuilder<int>(
              stream: cubit.select((state) => state.count),
              builder: (context, snapshot) {
                if (kDebugMode) {
                  print("Rebuild count");
                }
                return Text(
                  'Count: ${snapshot.data ?? 0}',
                  style: const TextStyle(fontSize: 24),
                );
              },
            ),
            // Only rebuilds when 'isEven' changes
            StreamBuilder<bool>(
              stream: cubit.select((state) => state.isEven),
              builder: (context, snapshot) {
                if (kDebugMode) {
                  print("Rebuild title");
                }
                return Text(
                  snapshot.data == true ? 'Even' : 'Odd',
                  style: const TextStyle(fontSize: 24),
                );
              },
            ),
            ElevatedButton(
              onPressed: cubit.increment,
              child: const Text('Increment'),
            ),

            ElevatedButton(
              onPressed: cubit.updateLabel,
              child: const Text('Update label'),
            ),
            ElevatedButton(
              onPressed: cubit.reset,
              child: const Text('Reset state'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return Provider(
                        create: (BuildContext context) => CounterMessageCubit(),
                        child: const DetailScreen(),
                      );
                    },
                  ),
                );
              },
              child: const Text('Go to detail'),
            ),
          ],
        ),
        Container(
          color: Colors.transparent,
          child: StreamBuilder<bool>(
            stream: cubit.select((state) => state.isLoading),
            builder: (context, snapshot) {
              if (kDebugMode) {
                print("Rebuild Loading");
              }
              return Offstage(
                offstage: !(snapshot.data ?? false),
                child: const IgnorePointer(
                  ignoring: true,
                  child: SizedBox.expand(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


```

Trong ví dụ này:

- Một `counterCubit` được tạo với giá trị ban đầu.
- Stream lắng nghe các thay đổi và in ra giá trị đếm mới.
- Hỗ trợ asynchronous và synchronous operation.
- State có thể được reset về giá trị ban đầu.
- Cubit được đóng khi không còn cần thiết để tránh rò rỉ bộ nhớ.
- Sử dung observer để debug vòng đời của `RxCubit`

---
