import 'dart:collection';
import 'dart:isolate';

import 'package:ftpconnect/ftpconnect.dart';
import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;

import '../config.dart';
import '../property.dart';
import '../tester.dart';

part 'ftp.dart';
part 'http.dart';

abstract class _AsserestTester<T extends AsserestProperty>
    implements AsserestTester {
  final T property;

  _AsserestTester(this.property);
}

class AsserestParallelTester extends UnmodifiableListView<AsserestTester> {
  final AsserestConfig _configuration;

  AsserestParallelTester._(Iterable<AsserestTester> source,
      [this._configuration = const AsserestConfig()])
      : super(source);

  Stream<AsserestReport> runAllTest() async* {
    /* for (AsserestTester tester in this) {
      AsserestReport report;
    } */
  }
}