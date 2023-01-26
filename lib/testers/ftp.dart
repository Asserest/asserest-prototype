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
      await ftpConn.connect();

      for (String dirName in property.url.pathSegments) {
        if (!await ftpConn.changeDirectory(dirName)) {
          if (!await ftpConn.existFile(dirName)) {
            return AsserestReport(property.url, property.accessible, false);
          }
        }
      }

      return AsserestReport(property.url, property.accessible, true);
    } on FTPConnectException {
      return AsserestReport(property.url, property.accessible, false);
    } catch (err) {
      return AsserestReport(
          property.url, property.accessible, null); // Internal errors throw.
    } finally {
      try {
        // Terminate connection no matter is established or not.
        await ftpConn.disconnect();
        // ignore: empty_catches
      } catch (err) {}
    }
  }
}
