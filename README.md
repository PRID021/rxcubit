
# rxbloc

`rxbloc` is a state management package for Flutter applications, built using `rxdart` and `provider`. It simplifies managing and observing state with reactive streams.

## Features

- Use of `rxdart` for handling state changes with streams.
- Supports synchronous and asynchronous state updates.
- Provides an easy-to-use API for state management.
- Allows tracking of state changes and errors through an observer pattern.
- Enables easy integration into existing Flutter apps with minimal boilerplate.

## Installation

To use this package in your Flutter project, add the following dependency in your `pubspec.yaml`:

```yaml
dependencies:
  rxbloc: ^0.0.1
```

## Usage

Here’s an example of how to use `rxbloc` in your application:

```dart
import 'package:rxbloc/rxbloc.dart';

class CounterCubit extends RxCubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}

final counterCubit = CounterCubit();

void main() {
  counterCubit.increment();
  print(counterCubit.state);  // Outputs: 1
}
```

## Contributing

If you'd like to contribute to this project, please fork the repository and submit a pull request. Make sure to follow the project's coding style and write tests for any new functionality.

## License

This package is licensed under the BSD-3-Clause License. See the [LICENSE](LICENSE) file for more details.

## Acknowledgments

- `rxdart` for providing powerful reactive streams.
- `provider` for its simplicity in state management.
