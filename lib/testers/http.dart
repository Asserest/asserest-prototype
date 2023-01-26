part of 'tester.dart';

class AsserestHTTPTester extends _AsserestTester<AsserestHTTPProperty> {
  AsserestHTTPTester._(super.property);

  Future<int> _makeResponse() async {
    Request req = Request(property.method, property.url)
      ..followRedirects = true;

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
      int count = 0;

      while (++count <= (property.tryCount ?? 1)) {
        result = await _makeResponse() == 200;
      }

      return AsserestReport(property.url, property.accessible, result);
    } catch (err) {
      if (err is ArgumentError && err.name == "method") {
        rethrow;
      }

      return AsserestReport(property.url, property.accessible, null);
    }
  }
}
