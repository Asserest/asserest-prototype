import 'package:args/args.dart';
import 'package:asserest/config.dart';

void main(List<String> arguments) {
  final ArgParser testParser = ArgParser()
    ..addOption("thread",
        abbr: "t",
        help: "Decide number of processors uses for assertion (At least one for base program and another one for assertion).",
        defaultsTo: "2")
    ..addFlag("ignore-error",
        help: "Basically just ignore URL that causing error during parsing.",
        defaultsTo: false);

  final ArgParser parser = ArgParser(allowTrailingOptions: false).addCommand("assert", testParser);
  final ArgResults args = parser.parse(arguments);

  int tNo;
  try {
    tNo = int.parse(args["thread"]);
    if (tNo-- < 2) {
      throw ArgParserException(
          "Thread number can not be lower than 2", arguments);
    }
  } on FormatException {
    tNo = 1;
  }

  final AsserestConfig config = AsserestConfig(
      maxThreads: tNo,
      configErrorAction: args["ignore-error"]
          ? ConfigErrorAction.ignore
          : ConfigErrorAction.stop);
}
