import 'package:asserest/property.dart';
import 'package:asserest/tester.dart';
import 'package:test/test.dart';

void main() {
  late AsserestParallelTester mockTester;

  setUpAll(() async {
    mockTester = AsserestParallelTester.fromProperties(
        await AsserestProperties.loadFromFile("test_assets/test_model_3.yaml"));
  });

  test("Try execute to get report", () {
    mockTester.runAllTest().onData(expectAsync1((report) {
      expect(
          [AsserestActualResult.success, AsserestActualResult.failure]
              .contains(report.actual),
          isTrue);
    }));
  });

  tearDownAll(() async {
    try {
      await mockTester.close();
    // ignore: empty_catches
    } catch (err) {}
  });
}
