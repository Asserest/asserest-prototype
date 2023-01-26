import 'dart:convert';

import 'package:meta/meta.dart';

import '../property.dart';

export 'testers/tester.dart';

enum AsserestActualResult {
  success,
  failure,
  error
}

@immutable
class AsserestReport {
  final Uri url;
  final bool expected;
  final AsserestActualResult actual;

  const AsserestReport(this.url, this.expected, this.actual);

  Map<String, dynamic> toMap() =>
      {"url": url.toString(), "expected": expected, "actual": actual.name};

  @override
  String toString() => jsonEncode(toMap());
}

abstract class AsserestTester<T extends AsserestProperty> {
  T get property;

  const AsserestTester._();
}