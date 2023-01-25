import 'package:meta/meta.dart';

import '../config.dart';
import '../property.dart';

@immutable
class AsserestReport {
  final Uri url;
  final bool expected;
  final bool? actual;

  const AsserestReport(this.url, this.expected, this.actual);

  Map<String, dynamic> toMap() =>
      {"url": url.toString(), "expected": expected, "actual": actual};

  @override
  String toString() => "$toMap()";
}

abstract class AsserestTester {
  const AsserestTester._();

  /// Execute assertion on accessing the given [AsserestProperty.url] value.
  Future<AsserestReport> runTest({AsserestConfig? config});
}