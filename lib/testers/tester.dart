import 'dart:async';
import 'dart:collection';
import 'dart:io';
//import 'dart:isolate';

import 'package:async_task/async_task.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:http/http.dart'
    hide delete, get, head, patch, post, put, read, readBytes, runWithClient;

import '../config.dart';
import '../property.dart';
import '../tester.dart';

part 'ftp.dart';
part 'http.dart';

abstract class _AsserestTester<T extends AsserestProperty> extends AsyncTask<T, AsserestReport>
    implements AsserestTester<T> {
  final T property;

  _AsserestTester(this.property);

  @override
  T parameters() => property;
}

class AsserestParallelTester extends UnmodifiableListView<AsserestTester> {
  final AsserestConfig _configuration;

  AsserestParallelTester._(Iterable<AsserestTester> source,
      [this._configuration = const AsserestConfig()])
      : super(source);

  Stream<AsserestReport> runAllTest() async* {
    
  }
}
