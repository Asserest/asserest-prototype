part of '../property.dart';

/// [AsserestProperty] for FTP protocol.
class AsserestFTPProperty extends AsserestProperty {
  /// Username for accessing FTP server.
  final String? username;

  /// Password for accessing FTP server.
  final String? password;

  /// Specify [ftpconn.SecurityType] uses for FTP connection.
  final ftpconn.SecurityType security;

  AsserestFTPProperty._(Uri url, this.username, this.password,
      this.security, bool accessible, int timeout, int? tryCount)
      : super._(url, accessible, timeout, tryCount);

  @override
  int get hashCode =>
      super.hashCode + quiver.hash3(username, password, security);

  @override
  bool operator ==(Object other) =>
      other is AsserestFTPProperty && hashCode == other.hashCode;
}