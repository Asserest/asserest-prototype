import 'package:asserest/property.dart';
import 'package:test/test.dart';

void main() {
  group("Valid YAML format", () {
    late AsserestProperties mockProperties;

    setUpAll(() async {
      mockProperties = await AsserestProperties.loadFromFile(
          "test_assets/test_model_1.yaml");
    });

    test("get testerS count", () {
      expect(
          mockProperties.whereType<AsserestHTTPProperty>().length, equals(2));
      expect(mockProperties.whereType<AsserestFTPProperty>().length, equals(1));
    });
  });
  group("Invalid YAML", () {
    test("format", () {
      expect(AsserestProperties.loadFromFile("test_assets/test_model_2.yaml"),
          throwsArgumentError);
    });
  });
}
