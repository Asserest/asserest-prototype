import 'package:asserest/property.dart';
import 'package:test/test.dart';

void main() {
  group("Individual type property", () {
    group("HTTP", () {
      test("disallow null body for some requests", () {
        expect(
            () => AsserestProperty.createHttp(
                url: "example.com", method: "GET", tryCount: 1),
            returnsNormally);
        expect(
            () => AsserestProperty.createHttp(
                url: "example.com", method: "HEAD", tryCount: 1),
            returnsNormally);
        expect(
            () => AsserestProperty.createHttp(
                url: "example.com", method: "DELETE", tryCount: 1),
            throwsArgumentError);
        expect(
            () => AsserestProperty.createHttp(
                url: "example.com", method: "PUT", tryCount: 1),
            throwsArgumentError);
        expect(
            () => AsserestProperty.createHttp(
                url: "example.com", method: "POST", tryCount: 1),
            throwsArgumentError);
        expect(
            () => AsserestProperty.createHttp(
                url: "example.com", method: "PATCH", tryCount: 1),
            throwsArgumentError);
      });
      test("parsing body with either List, Map or String", () {
        expect(
            () => AsserestProperty.createHttp(
                url: "example.com",
                method: "GET",
                body: {"foo": 1},
                tryCount: 1),
            returnsNormally);
        expect(
            () => AsserestProperty.createHttp(
                url: "example.com",
                method: "GET",
                body: [1, 2, 3],
                tryCount: 1),
            returnsNormally);
        expect(
            () => AsserestProperty.createHttp(
                url: "example.com",
                method: "GET",
                body: "Sample text",
                tryCount: 1),
            returnsNormally);
        expect(
            () => AsserestProperty.createHttp(
                url: "example.com", method: "GET", body: 111, tryCount: 1),
            throwsA(isA<TypeError>()));
      });
    });
  });
}
