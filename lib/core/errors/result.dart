import 'failures.dart';

class Result<T> {
  final T? _data;
  final Failure? _failure;
  final bool _isOk;

  const Result._ok(T data) : _data = data, _failure = null, _isOk = true;

  const Result._fail(Failure failure)
    : _data = null,
      _failure = failure,
      _isOk = false;

  factory Result.ok(T data) => Result._ok(data);
  factory Result.fail(Failure failure) => Result._fail(failure);

  bool get isOk => _isOk;
  bool get isFail => !_isOk;

  T? get dataOrNull => _data;
  Failure? get failureOrNull => _failure;

  T get data {
    if (!_isOk) {
      throw Exception('Cannot get data from a failed result');
    }
    return _data as T;
  }

  Failure get failure {
    if (_isOk) {
      throw Exception('Cannot get failure from a successful result');
    }
    return _failure!;
  }
}
