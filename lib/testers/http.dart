part of 'tester.dart';

class UnknownHTTPMethodException implements Exception {
  final String method;
  final String message;

  UnknownHTTPMethodException._(this.method,
      [this.message = "This method is undefined on HTTP request."]);

  @override
  String toString() {
    StringBuffer buf = StringBuffer("UnknownHTTPMethodException: ")
      ..write(message)
      ..writeln("\tApplied method: ")
      ..write(method);

    return "$buf";
  }
}

class AsserestHTTPTester extends _AsserestTester<AsserestHTTPProperty> {
  AsserestHTTPTester._(super.property);

  Future<int> _makeResponse() async {
    Request req = Request(property.method, property.url)
      ..followRedirects = true;

    StreamedResponse resp = await Client().send(req);

    return resp.statusCode;
  }

  @override
  Future<AsserestReport> runTest({AsserestConfig config = const AsserestConfig()}) async {
    try {
      bool result = false;
      int count = 0;

      while (++count <= (property.tryCount ?? 1)) {
        result = await _makeResponse() == 200;
      }

      return AsserestReport(property.url, property.accessible, result);
    } catch (err) {
      if (err is ArgumentError && err.invalidValue == "method" && config.configErrorAction == ConfigErrorAction.stop) {
        rethrow;
      }

      return AsserestReport(property.url, property.accessible, null);
    }
  }
}
