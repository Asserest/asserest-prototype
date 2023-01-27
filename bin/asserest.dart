import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:asserest/config.dart';
import 'package:asserest/property.dart';
import 'package:asserest/tester.dart';
import 'package:path/path.dart' as path;
import 'package:sprintf/sprintf.dart';

import 'report.dart';

List<dynamic> _resolveConfig(List<String> arguments) {
  final ArgParser parser = ArgParser(allowTrailingOptions: false)
    ..addOption("thread",
        abbr: "t",
        help:
            "Decide number of processors uses for assertion (At least one for base program and another one for assertion).",
        defaultsTo: "1")
    ..addFlag("ignore-parse-error",
        help: "Basically just ignore URL that causing error during parsing.",
        defaultsTo: false,
        negatable: false)
    ..addFlag("help",
        abbr: "h",
        help: "Print usage of asserest.",
        defaultsTo: false,
        negatable: false);

  ArgResults args;

  try {
    args = parser.parse(arguments);
  } on FormatException catch (err) {
    print(err.message);
    exit(-1);
  }

  if (args["help"]) {
    String binName =
        Platform.executable.split(Platform.isWindows ? "\\" : "/").last;
    if (RegExp(r"^dart", dotAll: false, caseSensitive: Platform.isWindows)
        .hasMatch(binName)) {
      binName += " ${path.join('.', 'bin', 'asserest.dart')}";
    }

    StringBuffer buf = StringBuffer("Usage: ")
      ..write(binName)
      ..write(" [options] ")
      ..write("<YAML asserest script>")
      ..writeln()
      ..writeln("Options:")
      ..writeln(parser.usage);

    print(buf);
    exit(0);
  }

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
      configErrorAction: args["ignore-parse-error"]
          ? ConfigErrorAction.ignore
          : ConfigErrorAction.stop, /*stackTraceLog: args["stack-trace-log"]*/
    ),
    args.arguments.last
  ];
}

void main(List<String> arguments) async {
  final result = _resolveConfig(arguments);

  final config = result[0] as AsserestConfig;
  final testPath = result[1] as String;

  AsserestProperties aprop = await AsserestProperties.loadFromFile(testPath,
      errorAction: config.configErrorAction);
  AsserestParallelTester tester =
      AsserestParallelTester.fromProperties(aprop, threads: config.maxThreads);
  AsserestReportAnalyser analyser = AsserestReportAnalyser();

  print(sprintf(
      "%-10s %-48s %-13s %-13s", ["Status", "URL", "Expected", "Actual"]));

  StreamSubscription<AsserestReport> testProc = tester.runAllTest();

  void receiveData(AsserestReport report) {
    report.printReport();
    analyser.add(report);
  }

  void onComplete() async {
    await tester.close();

    StringBuffer buf = StringBuffer()
      ..writeln()
      ..writeln()
      ..writeln("\t====ASSEREST RESULT====\t")
      ..writeln("Success: ${analyser.successCount}")
      ..writeln("Failure: ${analyser.failureCount}")
      ..writeln("Error: ${analyser.errorCount}")
      ..writeln();

    print(buf);
  }

  testProc
    ..onData(receiveData)
    ..onDone(onComplete)
    ..onError((err) async {
      await tester.close();

      print(err);
    });
}
