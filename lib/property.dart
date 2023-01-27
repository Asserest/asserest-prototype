import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:asserest/config.dart';
import 'package:ftpconnect/ftpconnect.dart' as ftpconn;
import 'package:meta/meta.dart';
import 'package:quiver/core.dart' as quiver;
import 'package:yaml/yaml.dart'
    hide loadYaml, loadYamlDocument, loadYamlDocuments, loadYamlStream;

part 'properties/exceptions.dart';
part 'properties/http.dart';
part 'properties/ftp.dart';

/// Property uses for assertion in general.
@immutable
abstract class AsserestProperty {
  /// URL uses for test.
  final Uri url;

  /// Expect the [url] is accessible or not.
  final bool accessible;

  /// Define a duration in second that assume it not accessible when exceeded.
  final int timeout;

  /// Determine retry count for expected accessible for [url].
  final int? tryCount;

  const AsserestProperty._(
      this.url, this.accessible, this.timeout, this.tryCount)
      : assert(accessible ^ (tryCount == null)),
        assert(timeout >= 10 && timeout <= 120 && timeout % 5 == 0);

  /// Construct [AsserestHTTPProperty] which uses for testing HTTP(S) connections.
  static AsserestHTTPProperty createHttp(
          {required Uri url,
          required String method,
          Map<String, String> headers = const {},
          dynamic body,
          bool accessible = true,
          int timeout = 10,
          int? tryCount}) =>
      AsserestHTTPProperty._(url, method, UnmodifiableMapView(headers), body,
          accessible, timeout, tryCount);

  /// Construct [AsserestFTPProperty] which uses for testing FTP connections.
  static AsserestFTPProperty createFtp(
          {required Uri url,
          String? username,
          String? password,
          required ftpconn.SecurityType security,
          bool accessible = true,
          int timeout = 10,
          int? tryCount}) =>
      AsserestFTPProperty._(
          url, username, password, security, accessible, timeout, tryCount);

  /// Parse YAML formatted [map] to an object.
  factory AsserestProperty.parse(YamlMap map) {
    Uri url = Uri.parse(map["url"]);

    if (url.host.isEmpty) {
      // Do not uses relative URL for assertion.
      throw UnsupportUriFormatException._relative(url);
    }

    bool accessible = map["accessible"];
    int timeout = map["timeout"] ?? 10; // Default timeout value if omitted.
    if (timeout < 10) {
      timeout = 10;
    } else if (timeout % 5 != 0) {
      timeout -= timeout % 5;
    } else if (timeout > 120) {
      timeout = 120;
    }
    int? tryCount;

    if (accessible) {
      tryCount = map["try_count"];
      if (tryCount == null) {
        throw ArgumentError.notNull("try_count");
      }
    }

    switch (url.scheme) {
      case "http":
      case "https":
        return AsserestHTTPProperty._(
            url,
            map["method"],
            UnmodifiableMapView(map["header"] ?? {}),
            map["body"],
            accessible,
            timeout,
            tryCount);
      case "ftp":
        return AsserestFTPProperty._(
            url,
            map["username"],
            map["password"],
            ftpconn.SecurityType.values.byName(map["security"] as String),
            accessible,
            timeout,
            tryCount);
      default:
        // Other scheme may no able to find solution.
        throw UnsupportUriFormatException._scheme(url);
    }
  }

  @override
  int get hashCode {
    int ohc = (tryCount == null)
        ? quiver.hash3(url, accessible, timeout)
        : quiver.hash4(url, accessible, timeout, tryCount);

    return ohc + url.hashCode % (tryCount != null ? 37 : 29);
  }

  @override
  bool operator ==(Object other) =>
      other is AsserestProperty && hashCode == other.hashCode;
}

/// Collect multiple [AsserestProperty] to unmodifiable [Iterable] form for batch
/// assertion.
class AsserestProperties<T extends AsserestProperty>
    extends UnmodifiableListView<T> {
  AsserestProperties._(super.source);

  /// Parse [YamlList] to the property.
  ///
  /// If [ignoreError] is `true`, it ignores the property that [Error] thrown.
  factory AsserestProperties.parse(YamlList list,
      {ConfigErrorAction errorAction = ConfigErrorAction.stop}) {
    List<T> lap = [];

    for (var node in list) {
      try {
        lap.add(AsserestProperty.parse(node) as T);
      } on Error {
        switch (errorAction) {
          case ConfigErrorAction.stop:
            // Stop if error is specified.
            rethrow;
          case ConfigErrorAction.ignore:
            continue;
          default:
            throw UnimplementedError(
                "Error action $errorAction is not defined");
        }
      }
    }

    return AsserestProperties._(lap);
  }

  /// Load [AsserestProperties] from [config] [String].
  static Future<AsserestProperties<T>> load<T extends AsserestProperty>(
          String config,
          {ConfigErrorAction errorAction = ConfigErrorAction.stop}) =>
      Isolate.run<AsserestProperties<T>>(
          () => AsserestProperties.parse(loadYamlNode(config) as YamlList,
              errorAction: errorAction),
          debugName: "Tester string reader");

  /// Load [AsserestProperties] from YAML file.
  ///
  /// The file extension must be either `.yml` or `.yaml`.
  static Future<AsserestProperties<T>> loadFromFile<T extends AsserestProperty>(
          String path,
          {Encoding encoding = utf8,
          ConfigErrorAction errorAction = ConfigErrorAction.stop}) =>
      Isolate.run<AsserestProperties<T>>(() async {
        File confFile = File(path);

        if (!RegExp(r"\.ya?ml$", caseSensitive: false).hasMatch(path)) {
          /*
            The file must be either .yml or .yaml ended.

            Parsing invalid file extension will throw FileSystemException,
            no matter the content is YAML or not.
           */
          throw FileSystemException(
              "Only accept file extension either .yml or .yaml", path);
        } else if (!await confFile.exists()) {
          // File does not existed.
          throw FileSystemException("This file does not existed", path);
        }

        try {
          return AsserestProperties.parse(
              loadYamlNode(await confFile.readAsString(encoding: encoding))
                  as YamlList,
              errorAction: errorAction);
        } on YamlException catch (ymlerr) {
          throw YamlFileException._(
              ymlerr, "The file content is not a standard YAML format", path);
        }
      }, debugName: "Tester file reader");
}
