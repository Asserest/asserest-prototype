import 'package:meta/meta.dart';

/// Determine action when internal [Error] thrown.
///
/// This action does not applied with [Exception].
enum ConfigErrorAction {
  /// Skip the action that causing [Error].
  ignore,

  /// Terminate this program and print [StackTrace] if possible.
  stop
}

@immutable
class AsserestConfig {
  /// Define action when one of the [Error] thrown during process.
  ///
  /// Default is [ConfigErrorAction.stop].
  final ConfigErrorAction configErrorAction;

  /// Number of processor uses for assertion.
  ///
  /// This value must be non-zero positive.
  final int maxThreads;

  /// Parse configuration options
  const AsserestConfig(
      {this.configErrorAction = ConfigErrorAction.stop, this.maxThreads = 1})
      : assert(maxThreads > 0);
}
