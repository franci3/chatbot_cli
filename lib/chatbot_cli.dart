import 'package:cli_util/cli_logging.dart';
import 'package:google_gemini/google_gemini.dart';

GoogleGemini? gemini;
final logger = Logger.standard();

void generateResponse(String input, String apiKey) async {
  gemini = GoogleGemini(apiKey: apiKey);
  final progress = logger.progress('Generating your query: $input');
  await gemini
      ?.generateFromText(input)
      .then((value) => logger.stdout(logger.ansi.emphasized(value.text)))
      .catchError((e) => logger.stderr(e));
  progress.finish(showTiming: true);
}
