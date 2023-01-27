import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
//import 'dart:isolate';

import 'package:async_task/async_task.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;
import 'package:meta/meta.dart';

import '../property.dart';
import '../tester.dart';

part 'ftp.dart';
part 'http.dart';

abstract class _AsserestTester<T extends AsserestProperty>
    extends AsyncTask<T, AsserestReport> implements AsserestTester<T> {
  @override
  final T property;

  _AsserestTester(this.property);

  @override
  T parameters() => property;
}

@immutable
class _AsserestReport implements AsserestReport {
  @override
  final Uri url;

  @override
  final bool expected;
  
  @override
  final AsserestActualResult actual;

  const _AsserestReport(this.url, this.expected, this.actual);

  @override
  Map<String, dynamic> toMap() =>
      {"url": url.toString(), "expected": expected, "actual": actual.name};

  @override
  String toString() => "AsserestReport$jsonEncode(toMap())";
}

List<AsyncTask> _tlr() => [
      AsserestHTTPTester._(
          AsserestProperty.createHttp(url: "example.com", method: "GET", tryCount: 1)),
      AsserestFTPTester._(
          AsserestProperty.createFtp(url: "example.com", security: SecurityType.FTP))
    ];

abstract class AsserestParallelTester<T extends AsserestTester>
    implements UnmodifiableListView<T> {
  // ignore: unused_element
  const AsserestParallelTester._();

  factory AsserestParallelTester(Iterable<T> source, {int threads = 1}) =>
      _AsserestParallelTester(source.cast<_AsserestTester>(), threads)
          as AsserestParallelTester<T>;

  factory AsserestParallelTester.fromProperties(AsserestProperties properties, {int threads = 1}) =>
  _AsserestParallelTester(properties.map<_AsserestTester>((e) {
    switch (e.runtimeType) {
      case AsserestHTTPProperty:
        return AsserestHTTPTester._(e as AsserestHTTPProperty);
      case AsserestFTPProperty:
        return AsserestFTPTester._(e as AsserestFTPProperty);
      default:
        throw TypeError();
    }
  })) as AsserestParallelTester<T>;

  Stream<AsserestReport> runAllTest();

  Future<bool> close();
}

class _AsserestParallelTester extends UnmodifiableListView<_AsserestTester>
    implements AsserestParallelTester<_AsserestTester> {
  final AsyncExecutor _ae;

  _AsserestParallelTester(super.source, [int threads = 1])
      : _ae = AsyncExecutor(
            sequential: false,
            parallelism: threads > Platform.numberOfProcessors
                ? Platform.numberOfProcessors
                : threads,
            taskTypeRegister: _tlr);

  @override
  Stream<AsserestReport> runAllTest() {
    return Stream.fromFutures(_ae.executeAll(this));
  }

  @override
  Future<bool> close() {
    return _ae.close();
  }
}
