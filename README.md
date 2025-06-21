# Chatbot CLI

A command-line interface (CLI) application to interact with Google's Gemini models. You can use it for single queries, queries with file context, or to start an interactive chat session.

This tool uses `bat` to provide nicely formatted Markdown output directly in your terminal.

## Prerequisites

1.  **Google Gemini API Key:**
    *   You need an API key from Google AI Studio to use this application.
    *   You can obtain one here: https://aistudio.google.com/

2.  **`bat` Installation:**
    *   `bat` is used to display the model's responses with syntax highlighting and Markdown formatting in the terminal.
    *   Installation instructions for `bat` can be found here: https://github.com/sharkdp/bat
    *   For example, on macOS with Homebrew: `brew install bat`
    *   On Debian/Ubuntu: `sudo apt install bat` (the command might be `batcat`)

## Setup

1.  **Clone the Repository (if you haven't already)**
2.  **Get your api key for using Google AI Studio.**
3.  **Build the dart program via `dart compile exe bin/chatbot_cli.dart -o chatbot.exe --target-os macos --define=API_KEY={YOUR_API_KEY} --define=TMP_FILE_PATH={PATH_TO_DIRECTORY_TO_SAVE_RESPONSES}`**
   4. **NOTE:** Adjust the target os you're running on
5.  **Then you can simply run the executable**

## Options (Flags)

*   `-i, --input <prompt>`: **(Mandatory)** The input prompt or your initial message to the model.
*   `-f, --file <path/to/file>`: (Optional) Specify a path to a file to include as context for your query. This is not supported in chat mode (`-c`).
*   `-d, --delete`: (Optional) Model responses are temporarily saved to a file for `bat` to process. Use this flag if you want this temporary file to be deleted after the run. By default, temporary files are kept.
*   `-c, --chat`: (Optional) Start an interactive chat session with the model. If this flag is used, the `-f` (file) flag is not supported.

## Examples

1.  **Single Query:**
    ```bash
    chatbot_cli.exe -i "What is the capital of France?"
    ```

2.  **Single Query and Delete Temporary File:**
    ```bash
    chatbot_cli.exe -i "Explain quantum entanglement in simple terms." -d
    ```

3.  **Query with a File as Context:**
    (Ensure `my_document.txt` exists)
    ```bash
    chatbot_cli.exe -i "Summarize this document for me" -f "path/to/my_document.txt"
    ```

4.  **Start an Interactive Chat Session:**
    ```bash
    chatbot_cli.exe -i "Hello, let's talk about space exploration." -c
    ```
    After the initial response, you can type your follow-up messages directly into the terminal and press Enter. To stop the chat just exit the program.

## How it Works

1.  You provide a prompt (and optionally a file).
2.  The CLI sends your request to the configured Google Gemini model.
3.  The model's response (which is requested in Markdown format) is received.
4.  This response is saved to a temporary Markdown file.
5.  `bat` is then used to display the content of this temporary file in your terminal, providing rich formatting.
6.  The temporary file can be automatically deleted if the `-d` flag is used.

---

## Roadmap

1. The interactive chat will be able to also include files
2. Currently, there is only one supported model `gemini-2.5-flash` but there are more to come
3. Code cleanup (everything is kinda functional now)
4. More options to adjust the model, basically everything that the `google_generative_ai` package allows. Since it is deprecated though it will be also maintained (**NOTE** See the fork in [pubspec.yaml](pubspec.yaml))
5. Creating files and also saving chat history
    