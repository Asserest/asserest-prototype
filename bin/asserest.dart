import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:args/args.dart';
import 'package:asserest/config.dart';
import 'package:asserest/property.dart';
import 'package:asserest/tester.dart';
import 'package:path/path.dart' as path;
import 'package:stack_trace/stack_trace.dart';

import 'report.dart';

String get _errorLogPath {
  String? homeDir =
      Platform.environment["HOME"] ?? Platform.environment["USERPROFILE"];
  DateTime currentDT = DateTime.now();

  return path.join(homeDir!, ".asserest",
      "${currentDT.year}${currentDT.month}${currentDT.day}_${currentDT.hour}${currentDT.minute}${currentDT.second}_${currentDT.millisecond}${currentDT.microsecond}.log");
}

List<dynamic> _resolveConfig(List<String> arguments) {
  final ArgParser parser = ArgParser()
    ..addOption("thread",
        abbr: "t",
        help:
            "Decide number of processors uses for assertion (At least one for base program and another one for assertion).",
        defaultsTo: "2")
    ..addFlag("ignore-parse-error",
        help: "Basically just ignore URL that causing error during parsing.",
        defaultsTo: false)
    ..addFlag("stack-trace-log",
        help: "Get stack trace log file under the home directory.",
        defaultsTo: false);

  final ArgResults args = parser.parse(arguments);

  int tNo;
  try {
    tNo = int.parse(args["thread"]);
    if (tNo < 1) {
      throw ArgParserException(
          "Thread number can not be lower than 1", arguments);
    }
  } on FormatException {
    tNo = 1;
  }

  return [
    AsserestConfig(
        maxThreads: tNo,
        configErrorAction: args["ignore-error"]
            ? ConfigErrorAction.ignore
            : ConfigErrorAction.stop,
        stackTraceLog: args["stack-trace-log"]),
    args.arguments.first
  ];
}

void main(List<String> arguments) async {
  final result = _resolveConfig(arguments);

  final config = result[0] as AsserestConfig;
  final testPath = result[1] as String;

  AsserestProperties aprop = await AsserestProperties.loadFromFile(testPath);
  AsserestParallelTester tester =
      AsserestParallelTester.fromProperties(aprop, threads: config.maxThreads);
  AsserestReportAnalyser analyser = AsserestReportAnalyser();

  Stream<AsserestReport> testProc = Chain.capture(tester.runAllTest);
  testProc.listen((report) {
    report.printReport();
    analyser.add(report);
  }, onDone: () async {
    await tester.close();

    StringBuffer buf = StringBuffer()
      ..writeln()
      ..writeln()
      ..writeln("\t====ASSEREST RESULT====\t")
      ..writeln("Success: ${analyser.successCount}")
      ..writeln("Failure: ${analyser.errorCount}")
      ..writeln("Error: ${analyser.errorCount}");

    if (analyser.hasError) {
      final ccap = Chain.current(5);
      final filename = _errorLogPath;
      
      await Isolate.run(() async {
        File logFile = File(filename);
        await logFile.writeAsString(ccap.toString(), mode: FileMode.writeOnly, encoding: utf8);
      });

      buf..writeln()..writeln("The error log file save into $filename");
    }

    buf.writeln();

    print(buf);
  });
}
