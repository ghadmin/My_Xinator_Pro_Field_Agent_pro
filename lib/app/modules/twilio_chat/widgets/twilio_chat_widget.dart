import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TwilioChatWidget extends StatefulWidget {
  const TwilioChatWidget({super.key});

  @override
  State<TwilioChatWidget> createState() => _TwilioChatWidgetState();
}

class _TwilioChatWidgetState extends State<TwilioChatWidget> {
  final String deploymentKey = "CV3f77a09d303f49b7f274d5ad541095b8";

  bool isLoading = true;
  String? error;

  @override
  Widget build(BuildContext context) {
    final html = '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<script defer src="https://media.twiliocdn.com/sdk/js/webchat-v3/releases/3.3.0/webchat.min.js"></script>

<style>
html, body {
  margin:0;
  padding:0;
  height:100%;
  width:100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-family: Arial, sans-serif;
}
#twilio-webchat-widget-root {
  height:100vh;
  width:100vw;
}
.chat-hint {
  position: absolute;
  bottom: 30px;
  left: 50%;
  transform: translateX(-50%);
  background: white;
  color: #333;
  padding: 20px 32px;
  border-radius: 16px;
  font-size: 16px;
  font-weight: 500;
  z-index: 1;
  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
  text-align: center;
  display: flex;
  align-items: center;
  gap: 12px;
}
.chat-hint::before {
  content: "💬";
  font-size: 20px;
}
.chat-hint.hidden {
  display: none;
}
</style>
</head>

<body>

<div id="twilio-webchat-widget-root"></div>
<div class="chat-hint">Click on the icon to start chat</div>

<script>
window.addEventListener("load", function () {
  console.log("Initializing Twilio WebChat...");

  Twilio.initWebchat({
    deploymentKey: "$deploymentKey",
    startEngagementOnInit: true
  })
  .then(() => console.log("Twilio WebChat ready"))
  .catch(e => console.error("Twilio init failed:", e));

  // Hide hint on tap/click anywhere
  document.addEventListener('click', function() {
    const hint = document.querySelector('.chat-hint');
    if (hint) {
      hint.classList.add('hidden');
    }
  });
});
</script>

</body>
</html>
''';

    return Column(
      children: [
        // Custom AppBar
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              const Text(
                "Support Chat",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // WebView content
        Expanded(
          child: Stack(
            children: [
              /// WebView
              InAppWebView(
                initialData: InAppWebViewInitialData(
                  data: html,

                  /// IMPORTANT — must match Twilio allowed origin
                  baseUrl: WebUri("https://jobs-msschedules.myserviceforce.com"),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  thirdPartyCookiesEnabled: true,
                  mediaPlaybackRequiresUserGesture: false,
                  clearCache: true,
                  useOnLoadResource: true,
                  useHybridComposition: true,
                  verticalScrollBarEnabled: true,
                ),
                onLoadStop: (controller, url) {
                  setState(() => isLoading = false);
                },
                onConsoleMessage: (controller, msg) {
                  debugPrint("WEB: ${msg.message}");
                },
                onReceivedError: (controller, request, err) {
                  setState(() {
                    error = err.description;
                    isLoading = false;
                  });
                },
              ),

              /// Loading overlay
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              /// Error overlay
              if (error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      "Failed to load chat\n$error",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
