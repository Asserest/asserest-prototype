import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:ftpconnect/ftpconnect.dart' as ftpconn;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path show isAbsolute;
import 'package:quiver/core.dart' as quiver;
import 'package:yaml/yaml.dart'
    hide loadYaml, loadYamlDocument, loadYamlDocuments, loadYamlStream;

/// It thrown when [Uri] has invalid format.
class UnsupportUriFormatException extends FormatException {
  UnsupportUriFormatException._scheme(Uri uri)
      : super("This URL's scheme does not supported yet.", uri);

  UnsupportUriFormatException._relative(Uri uri)
      : super("URL must be an absolute path.", uri);
}

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

  factory AsserestProperty.http(
          {required Uri url,
          required String method,
          Map<String, String> headers = const {},
          dynamic body,
          bool accessible = true,
          int timeout = 10,
          int? tryCount}) =>
      AsserestHTTPProperty._(url, method, UnmodifiableMapView(headers), body,
          accessible, timeout, tryCount);

  factory AsserestProperty.ftp(
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

    if (!path.isAbsolute("$url")) {
      // Do not uses relative URL for assertion.
      throw UnsupportUriFormatException._relative(url);
    }

    bool accessible = map["accessible"];
    int timeout = map["timeout"] ?? 10; // Default timeout value if omitted.
    int? tryCount;

    if (accessible) {
      tryCount = map["tryCount"] ?? 1;
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

/// [AsserestProperty] for HTTP protocol.
class AsserestHTTPProperty extends AsserestProperty {
  /// Method uses for making HTTP request.
  final String method;

  /// Header that uses for request.
  final UnmodifiableMapView<String, String> headers;

  /// Body content for making requedt.
  ///
  /// It must be `null` when using `GET` and `HEAD` methods and required
  /// either [Map] or [String]. If using [Map], it will be convert to
  /// JSON [String] automatically.
  final dynamic body;

  const AsserestHTTPProperty._(Uri url, this.method, this.headers, this.body,
      bool accessible, int timeout, int? tryCount)
      : super._(url, accessible, timeout, tryCount);

  @override
  int get hashCode => super.hashCode + quiver.hash3(method, headers, body);

  @override
  bool operator ==(Object other) =>
      other is AsserestHTTPProperty && hashCode == other.hashCode;
}

/// [AsserestProperty] for FTP protocol.
class AsserestFTPProperty extends AsserestProperty {
  /// Username for accessing FTP server.
  final String? username;

  /// Password for accessing FTP server.
  final String? password;

  /// Specify [ftpconn.SecurityType] uses for FTP connection.
  final ftpconn.SecurityType security;

  const AsserestFTPProperty._(Uri url, this.username, this.password,
      this.security, bool accessible, int timeout, int? tryCount)
      : super._(url, accessible, timeout, tryCount);

  @override
  int get hashCode =>
      super.hashCode + quiver.hash3(username, password, security);

  @override
  bool operator ==(Object other) =>
      other is AsserestFTPProperty && hashCode == other.hashCode;
}

/// Collect multiple [AsserestProperty] to unmodifiable [Iterable] form for batch
/// assertion.
class AsserestProperties<T extends AsserestProperty>
    extends UnmodifiableListView<T> {
  AsserestProperties._(super.source);

  /// Parse [YamlList] to the property.
  ///
  /// If [ignoreError] is `true`, it ignores the property that [Error] thrown.
  factory AsserestProperties.parse(YamlList list, {bool ignoreError = false}) {
    List<T> lap = [];

    for (var node in list) {
      try {
        lap.add(AsserestProperty.parse(node) as T);
      } on Error {
        if (!ignoreError) {
          // Stop if error is specified.
          rethrow;
        }
      }
    }

    return AsserestProperties._(lap);
  }

  /// Load [AsserestProperties] from [config] [String].
  static Future<AsserestProperties<T>> load<T extends AsserestProperty>(
          String config) =>
      Isolate.run<AsserestProperties<T>>(
          () => AsserestProperties.parse(loadYamlNode(config) as YamlList),
          debugName: "Tester string reader");

  /// Load [AsserestProperties] from YAML file.
  ///
  /// The file extension must be either `.yml` or `.yaml`.
  static Future<AsserestProperties<T>> loadFromFile<T extends AsserestProperty>(
          String path) =>
      Isolate.run<AsserestProperties<T>>(() async {
        File confFile = File(path);

        if (!RegExp(r"\.ya?ml$").hasMatch(path.toLowerCase())) {
          throw FileSystemException(
              "Only accept file extension either .yml or .yaml", path);
        } else if (!await confFile.exists()) {
          throw FileSystemException("This file does not existed", path);
        }

        return AsserestProperties.parse(
            loadYamlNode(await confFile.readAsString(encoding: utf8))
                as YamlList);
      }, debugName: "Tester file reader");
}
