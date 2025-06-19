import 'package:args/args.dart';
import 'package:chatbot_cli/chatbot_cli.dart' as chatbot_cli;
import 'package:chatbot_cli/chatbot_cli_arguments.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption(input,
        abbr: 'i', mandatory: true, help: 'Input Prompt - Mandatory')
    ..addOption(file, abbr: 'f', help: 'Specify a file to a path')
    ..addFlag(delete,
        abbr: 'd',
        help:
            'Model Responses will be saved in a tmp file, specify if should be deleted after run')
    ..addFlag(chat, abbr: 'c', help: 'Start a chat');

  ArgResults argResults = parser.parse(arguments);

  chatbot_cli.validateArguments(argResults);

  chatbot_cli.generateResponse(argResults);
}
