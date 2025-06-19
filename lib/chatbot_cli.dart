import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:chatbot_cli/chatbot_cli_arguments.dart';
import 'package:chatbot_cli/chatbot_cli_models.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:dotenv/dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

final logger = Logger.standard();

void validateArguments(ArgResults argResult) {
  if (!argResult.options.contains(input)) {
    logger.stderr('input is mandatory');
    exit(1);
  }
  if (argResult.options.contains(file) &&
      (argResult.option(file) == null ||
          argResult.option(file)!.trim().isEmpty)) {
    logger.stderr('file cannot be null or empty');
    exit(1);
  }
}

String _loadApiKey() {
  final envFile = DotEnv(includePlatformEnvironment: true)..load();
  if (envFile['API_KEY'] == null) {
    logger.stderr('No .env file with API_KEY provided');
    exit(1);
  }
  return envFile['API_KEY']!;
}

Future<void> generateResponse(ArgResults argResults) async {
  final inputPrompt = argResults[input];
  final filePath = argResults[file] as String?;
  final deleteFile = argResults[delete] as bool;
  final startChat = argResults[chat] as bool;

  logger.write('\n');
  final GenerativeModel model = GenerativeModel(
      model: ChatbotCliModels.gemini25flash.modelName, apiKey: _loadApiKey());
  if (startChat) {
    if (filePath != null) {
      logger.stderr('Files are not yet supported when chatting');
      exit(1);
    }
    await _startChat(model, inputPrompt, deleteFile);
  } else {
    await _generateResponse(model, inputPrompt, filePath, deleteFile);
  }
}

Future<void> _startChat(
    GenerativeModel model, String inputPrompt, bool deleteFile) async {
  final ChatSession session = model.startChat();
  final response = await session.sendMessage(Content.text(inputPrompt));
  await _createOutput(response, deleteTmpFile: deleteFile);
  while (true) {
    final input = stdin.readLineSync(encoding: utf8);
    if (input != null) {
      final progress = logger.progress('');
      final response = await session.sendMessage(Content.text(input));
      await _createOutput(response, deleteTmpFile: deleteFile);
      progress.finish();
    }
  }
}

Future<void> _generateResponse(GenerativeModel model, String inputPrompt,
    String? filePath, bool deleteFile) async {
  final progress = logger.progress('Generating your query: $inputPrompt');
  await model
      .generateContent(await _getContent(inputPrompt, filePath))
      .then((value) async => await _createOutput(
            value,
            deleteTmpFile: deleteFile,
          ))
      .catchError((e) => logger.stderr(e));
  progress.finish();
}

Future<List<Content>> _getContent(String inputPrompt, String? filePath) async {
  List<Content> promptContents = [Content.text(inputPrompt)];
  if (filePath != null) {
    final mimeAndFile = await _readFile(filePath);
    promptContents.add(Content.data(mimeAndFile.$1, mimeAndFile.$2));
  }
  promptContents.add(Content.text('Please provide output in markdown format.'));
  return promptContents;
}

Future<void> _createOutput(GenerateContentResponse response,
    {bool deleteTmpFile = false}) async {
  if (response.text == null) {
    logger.stderr('Model response is empty');
    exit(1);
  }
  String? tmpFile;
  try {
    tmpFile = await _writeToTemporaryFile(response);
    final result = await _runBat(tmpFile);
    if (result.exitCode == 0) {
      logger.stdout(result.stdout);
    } else {
      throw Exception(result.stderr);
    }
  } catch (e) {
    logger.stderr('Failed to run bat process: $e');
    logger.stdout('--- Raw Model Response ---');
    logger.stdout(response.text!);
  } finally {
    if (deleteTmpFile && tmpFile != null) {
      await _deleteFile(tmpFile);
    }
  }
}

Future<String> _writeToTemporaryFile(GenerateContentResponse response) async {
  final timestamp = DateTime.now();
  final tmpFilePath =
      path.join('lib', 'tmp', '${timestamp.toIso8601String()}_tmp.md');
  final tmpFile = File(tmpFilePath);
  await tmpFile.writeAsString(response.text!);
  return tmpFilePath;
}

Future<void> _deleteFile(String path) async {
  await File(path).delete();
}

Future<(String, Uint8List)> _readFile(String path) async {
  final file = await File(path).readAsBytes();
  final mimeType = lookupMimeType(path);
  if (mimeType == null) {
    logger.stderr('Could not determine MimeType of file $path');
    exit(1);
  }
  return (mimeType, file);
}

Future<ProcessResult> _runBat(String filePath) async {
  return await Process.run(
    'bat',
    [filePath, '--paging=never', '--language=md', '-f'],
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
}
