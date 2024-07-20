import 'package:google_gemini/google_gemini.dart';

GoogleGemini? gemini;

void generateResponse(String input, String apiKey) async {
  gemini = GoogleGemini(apiKey: apiKey);

  gemini
      ?.generateFromText(input)
      .then((value) => print(value.text))
      .catchError((e) => print(e));
}
