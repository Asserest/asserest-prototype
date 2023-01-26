part of 'tester.dart';

class _FTPInaccessible implements Exception {
  const _FTPInaccessible();
}

/// Determine accessibility on FTP server by checking the given address.
/// 
/// This only test list permission only and it does not check read
/// (downloading file) or write (uploading file) permission.
class AsserestFTPTester extends _AsserestTester<AsserestFTPProperty> {
  AsserestFTPTester._(super.property);

  @override
  Future<AsserestReport> runTest({AsserestConfig config = const AsserestConfig()}) async {
    FTPConnect ftpConn = FTPConnect(property.url.host,
        port: property.url.port,
        user: property.username ?? "anonymous",
        pass: property.password ?? "",
        securityType: property.security,
        timeout: property.timeout,
        showLog: false);

    try {
      bool connected = await ftpConn.connect();
      if (!connected) {
        throw _FTPInaccessible();
      }

      for (String dirName in property.url.pathSegments) {
        if (!await ftpConn.changeDirectory(dirName)) {
          if (!await ftpConn.existFile(dirName)) {
            // When provided path is neither a directory nor a file.
            throw _FTPInaccessible();
          }
        }
      }

      return AsserestReport(property.url, property.accessible, true);
    } catch (err) {
      return AsserestReport(
          property.url,
          property.accessible,
          (err is FTPConnectException || err is _FTPInaccessible)
              ? false // Either connection or inaccessible
              : null); // Internal errors throw.
    } finally {
      try {
        // Terminate connection no matter is established or not.
        await ftpConn.disconnect();
        // ignore: empty_catches
      } catch (err) {}
    }
  }
}
