part of '../property.dart';

/// It thrown when [Uri] has invalid format.
class UnsupportUriFormatException extends FormatException {
  UnsupportUriFormatException._scheme(Uri uri)
      : super("This URL's scheme does not supported yet.", uri);

  UnsupportUriFormatException._relative(Uri uri)
      : super("URL must be an absolute path.", uri);

  @override
  String get message => "${super.message} (Parsed source $source)";
}

class YamlFileException extends FileSystemException {
  final YamlException _e;

  // ignore: unused_element
  YamlFileException._(this._e, super.message, [super.path, super.osError]);

  @override
  String get message {
    final buf = StringBuffer(super.message)
      ..write(" with following YamlException:")
      ..writeln("$_e");

    return buf.toString();
  }
}
