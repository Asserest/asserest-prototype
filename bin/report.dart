import 'dart:collection';

import 'package:ansicolor/ansicolor.dart';
import 'package:asserest/tester.dart' show AsserestReport, AsserestActualResult;

final AnsiPen ansiPen = AnsiPen();

extension AsserestReportPrinter on AsserestReport {
  void printReport() {
    try {
      String expTerm = expected ? "accessible" : "inaccessible"; 

      void passPrint() {
        ansiPen.xterm(46);
        print(ansiPen("[Pass]\t\t$url\t\tExpected $expTerm"));
      }

      void failPrint() {
        ansiPen.xterm(9);
        print(ansiPen("[Fail]\t\t$url\t\tExpected $expTerm"));
      }

      switch (actual) {
        case AsserestActualResult.success:
          if (expected) {
            passPrint();
          } else {
            failPrint();
          }
          break;
        case AsserestActualResult.failure:
          if (expected) {
            failPrint();
          } else {
            passPrint();
          }
          break;
        case AsserestActualResult.error:
          ansiPen
            ..yellow(bg: true)
            ..black(bold: true);
          print(ansiPen("$url cannot be tested due to internal error"));
          break;
      }
    } finally {
      ansiPen.reset();
    }
  }
}

class AsserestReportAnalyser extends ListBase<AsserestReport> {
  final List<AsserestReport> _report = [];

  static bool _findSuccess(AsserestReport element) =>
      (element.expected && element.actual == AsserestActualResult.success) ||
      (!element.expected && element.actual == AsserestActualResult.failure);

  static bool _findFailed(AsserestReport element) =>
      (!element.expected && element.actual == AsserestActualResult.success) ||
      (element.expected && element.actual == AsserestActualResult.failure);

  static bool _findError(AsserestReport element) =>
      element.actual == AsserestActualResult.error;

  AsserestReportAnalyser();

  @override
  set length(int newLength) => _report.length = length;

  @override
  int get length => _report.length;

  @override
  AsserestReport operator [](int index) => _report[index];

  @override
  void operator []=(int index, AsserestReport value) => _report[index] = value;

  Iterable<AsserestReport> get _errorIterable => _report.where(_findError);

  bool get hasError => _errorIterable.isNotEmpty;

  int get successCount => _report.where(_findSuccess).length;

  int get failureCount => _report.where(_findFailed).length;

  int get errorCount => _errorIterable.length;

  @override
  Iterator<AsserestReport> get iterator => _report.iterator;

  @override
  void add(AsserestReport element) {
    _report.add(element);
  }

  @override
  void addAll(Iterable<AsserestReport> iterable) {
    _report.addAll(iterable);
  }
}
