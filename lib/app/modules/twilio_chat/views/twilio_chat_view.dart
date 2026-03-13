import 'package:flutter/material.dart';

import '../widgets/twilio_chat_widget.dart';

class TwilioChatView extends StatefulWidget {
  const TwilioChatView({super.key});

  @override
  State<TwilioChatView> createState() => _TwilioChatViewState();
}

class _TwilioChatViewState extends State<TwilioChatView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            // Watermark logo in center
            Center(
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/images/splashIcon.png',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            // Chat widget on top
            const TwilioChatWidget(),
          ],
        ),
      ),
    );
  }
}
