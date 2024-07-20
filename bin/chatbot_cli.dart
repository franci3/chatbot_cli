import 'package:args/args.dart';
import 'package:chatbot_cli/chatbot_cli.dart' as chatbot_cli;
import 'package:chatbot_cli/chatbot_cli_arguments.dart';
import 'package:dotenv/dotenv.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption(question, defaultsTo: 'How are you?', abbr: 'q');

  ArgResults argResults = parser.parse(arguments);

  var env = DotEnv(includePlatformEnvironment: true)..load();

  chatbot_cli.generateResponse(argResults.option(question)!, env['API_KEY']!);
}
