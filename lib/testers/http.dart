part of 'tester.dart';

/// [AsserestTester] uses for testing HTTP connection.
class AsserestHTTPTester extends _AsserestTester<AsserestHTTPProperty> {
  AsserestHTTPTester._(super.property);

  Future<int> _makeResponse() async {
    Request req = Request(property.method, property.url)
      ..followRedirects = true;

    req.headers.addAll(property.headers);
    assert(["GET", "HEAD"].contains(property.method.toUpperCase()) || property.body != null);
    if (property.body != null) {
      String ctx;
      
      if (property.body is Map || property.body is List) {
        ctx = jsonEncode(property.body);
      } else {
        ctx = property.body!;
      }

      req.body = ctx;
    }

    StreamedResponse resp = await Client().send(req);

    return resp.statusCode;
  }

  @override
  AsyncTask<AsserestHTTPProperty, AsserestReport> instantiate(
          AsserestHTTPProperty parameters,
          [Map<String, SharedData>? sharedData]) =>
      AsserestHTTPTester._(parameters);

  @override
  FutureOr<AsserestReport> run() async {
    try {
      bool result = false;

      for (int count = 0; count < (property.tryCount ?? 1); count++) {
        result = await _makeResponse() == 200;
      }

      return _AsserestReport(property.url, property.accessible,
          result ? AsserestActualResult.success : AsserestActualResult.failure);
    } on ClientException {
      return _AsserestReport(
          property.url, property.accessible, AsserestActualResult.failure);
    } catch (err) {
      if (err is ArgumentError && err.name == "method") {
        rethrow;
      }

      return _AsserestReport(
          property.url, property.accessible, AsserestActualResult.error);
    }
  }
}
