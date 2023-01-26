part of 'tester.dart';

/// Determine accessibility on FTP server by checking the given address.
///
/// It only depends on accessibility of given path.
class AsserestFTPTester extends _AsserestTester<AsserestFTPProperty> {
  AsserestFTPTester._(super.property);

  @override
  AsyncTask<AsserestFTPProperty, AsserestReport> instantiate(
          AsserestFTPProperty parameters,
          [Map<String, SharedData>? sharedData]) =>
      AsserestFTPTester._(property);

  @override
  FutureOr<AsserestReport> run() async {
    FTPConnect ftpConn = FTPConnect(property.url.host,
        port: property.url.port,
        user: property.username ?? "anonymous",
        pass: property.password ?? "",
        securityType: property.security,
        timeout: property.timeout,
        showLog: false);

    try {
      bool result = false;

      await ftpConn.connect();

      for (int count = 0; count < (property.tryCount ?? 1); count++) {
        for (String dirName in property.url.pathSegments) {
          if (!await ftpConn.changeDirectory(dirName)) {
            result = await ftpConn.existFile(dirName);
          } else {
            result = true;
          }
        }
      }

      return AsserestReport(property.url, property.accessible, result ? AsserestActualResult.success : AsserestActualResult.failure);
    } on FTPConnectException {
      return AsserestReport(property.url, property.accessible, AsserestActualResult.failure);
    } catch (err) {
      return AsserestReport(
          property.url, property.accessible, AsserestActualResult.error); // Internal errors throw.
    } finally {
      try {
        // Terminate connection no matter is established or not.
        await ftpConn.disconnect();
        // ignore: empty_catches
      } catch (err) {}
    }
  }
}
