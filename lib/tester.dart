import 'package:meta/meta.dart';

import '../property.dart';

export 'testers/tester.dart';

/// Enumerated value to determine result of assertion.
enum AsserestActualResult {
  /// It matched expected result.
  success,

  /// It does not stastified expected result.
  failure,

  /// Any unexpected exception which not related to
  /// communication error.
  error
}

/// An archive of executed value from tester.
@immutable
abstract class AsserestReport {
  /// Tested URL address.
  Uri get url;

  /// A boolean for expected it can be access or not.
  bool get expected;

  /// An actual scenrino on local device when accessing
  /// given [url].
  AsserestActualResult get actual;

  const AsserestReport._();

  /// Generate JSON [Map] of all properties.
  Map<String, dynamic> toMap();

  /// Return stringified [toMap] with name of the
  /// class as a [String] value.
  @override
  String toString();
}

/// Test connectivity by given [property].
abstract class AsserestTester<T extends AsserestProperty> {
  /// An [AsserestProperty] uses for running this test.
  T get property;

  const AsserestTester._();
}
