// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dark_style.dart';
// from `flutterfire config`: https://firebase.google.com/docs/flutter/setup
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatefulWidget {
  static const title = 'Demo: hõiAI';
  static final themeMode = ValueNotifier(ThemeMode.light);

  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: App.themeMode,
    builder:
        (context, mode, child) => MaterialApp(
          title: App.title,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          home: ChatPage(),
          debugShowCheckedModeBanner: false,
        ),
  );
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
    lowerBound: 0.25,
    upperBound: 1.0,
  );

  late final _provider = FirebaseProvider(
    model: FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash-exp-image-generation',
    ),
  );

  final _halloweenMode = ValueNotifier(false);
  final _vietnameseMode = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _resetAnimation();
  }

  void _resetAnimation() {
    _animationController.value = 1.0;
    _animationController.reverse();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: _vietnameseMode, // _halloweenMode,
    builder:
        (context, vietnamese, child) => Scaffold(
          appBar: AppBar(
            title: const Text(App.title),
            actions: [
              IconButton(
                onPressed: _clearHistory,
                tooltip: 'Clear History',
                icon: const Icon(Icons.history),
              ),
              IconButton(
                onPressed:
                    () =>
                        App.themeMode.value =
                            App.themeMode.value == ThemeMode.light
                                ? ThemeMode.dark
                                : ThemeMode.light,
                tooltip:
                    App.themeMode.value == ThemeMode.light
                        ? 'Dark Mode'
                        : 'Light Mode',
                icon: const Icon(Icons.brightness_4_outlined),
              ),
              IconButton(
                onPressed: () {
                  _vietnameseMode.value = !_vietnameseMode.value;
                  if (_vietnameseMode.value) _resetAnimation();
                },
                tooltip:
                    _vietnameseMode.value ? 'Chế độ thường' : 'Chủ đề Việt Nam',
                icon: Text('🌾'),
              ),
              IconButton(
                onPressed: () async {
                  try {
                    final model = FirebaseAI.googleAI().generativeModel(
                      model: 'gemini-2.0-flash-exp-image-generation',
                      //'imagen-3.0-generate-002', // 'gemini-2.0-flash-exp',
                    );
                    final prompt = 'Show me photos of the pyramids';
                    print('Sending: $prompt');
                    final response = await model.generateContent([
                      Content.text(prompt),
                    ]);
                    print('Response: ${response.text}'); // ${response.text}');
                  } catch (e) {
                    print('Error: $e');
                  }
                },
                tooltip: 'Test',
                icon: Icon(Icons.bug_report),
                // child: Icon(Icons.bug_report),
              ),
              // IconButton(
              //   onPressed: () {
              //     _halloweenMode.value = !_halloweenMode.value;
              //     if (_halloweenMode.value) _resetAnimation();
              //   },
              //   tooltip:
              //       _halloweenMode.value ? 'Normal Mode' : 'Halloween Mode',
              //   icon: Text('🎃'),
              // ),
            ],
          ),
          body: AnimatedBuilder(
            animation: _animationController,
            builder:
                (context, child) => Stack(
                  children: [
                    if (_vietnameseMode.value)
                      SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/vietnamese-bg.jpg',
                          fit: BoxFit.cover,
                          opacity: _animationController,
                        ),
                      )
                    else if (_halloweenMode.value)
                      SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/halloween-bg.png',
                          fit: BoxFit.cover,
                          opacity: _animationController,
                        ),
                      ),
                    LlmChatView(
                      provider: _provider,
                      style: _vietnameseMode.value ? _vietnameseStyle : style,
                      welcomeMessage:
                          _vietnameseMode.value
                              ? 'Xin chào! Tôi là trợ lý ảo của bạn. Tôi có thể giúp gì cho bạn hôm nay?'
                              : 'Hello and welcome to the Flutter AI Toolkit!',
                      suggestions:
                          _vietnameseMode.value
                              ? [
                                'Giới thiệu về Việt Nam',
                                'Món ăn truyền thống Việt Nam',
                                'Địa điểm du lịch nổi tiếng',
                              ]
                              : [
                                'I\'m a Star Wars fan. What should I wear for Halloween?',
                                'I\'m allergic to peanuts. What candy should I avoid at Halloween?',
                                'What\'s the difference between a pumpkin and a squash?',
                              ],
                    ),
                  ],
                ),
          ),
        ),
  );

  void _clearHistory() {
    _provider.history = [];
    _resetAnimation();
  }

  LlmChatViewStyle get _vietnameseStyle {
    final TextStyle vietnameseTextStyle = GoogleFonts.notoSans(
      color: const Color(0xFF2E7D32), // Deep green
      fontSize: 14,
    );

    final Color primaryColor = const Color(0xFF2E7D32); // Green (rice fields)
    final Color accentColor = const Color(0xFFFFC107); // Gold (ripe rice)
    final Color backgroundColor = const Color(
      0xFFF1F8E9,
    ); // Light green (young rice)

    return LlmChatViewStyle(
      backgroundColor: Colors.transparent,
      progressIndicatorColor: primaryColor,
      suggestionStyle: SuggestionStyle(
        textStyle: vietnameseTextStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      chatInputStyle: ChatInputStyle(
        backgroundColor: Colors.white,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor),
        ),
        textStyle: vietnameseTextStyle,
        hintText: 'Nhập tin nhắn...',
        hintStyle: vietnameseTextStyle.copyWith(color: Colors.grey.shade600),
      ),
      userMessageStyle: UserMessageStyle(
        textStyle: vietnameseTextStyle.copyWith(color: Colors.white),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      llmMessageStyle: LlmMessageStyle(
        icon: Icons.grass, // Rice plant icon
        iconColor: Colors.white,
        iconDecoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4),
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: accentColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 4,
              offset: Offset(1, 1),
            ),
          ],
        ),
        markdownStyle: MarkdownStyleSheet(
          p: vietnameseTextStyle,
          listBullet: vietnameseTextStyle,
          h1: vietnameseTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
          img: vietnameseTextStyle,
          // Add more styles as needed
        ),
      ),
      // Style other components similarly
    );
  }

  // Halloween style
  LlmChatViewStyle get style {
    if (!_halloweenMode.value) {
      return App.themeMode.value == ThemeMode.dark
          ? darkChatViewStyle()
          : LlmChatViewStyle.defaultStyle();
    }

    // Halloween mode
    final TextStyle halloweenTextStyle = GoogleFonts.hennyPenny(
      color: Colors.white,
      fontSize: 24,
    );

    final TextStyle halloweenMenuItemTextStyle = GoogleFonts.hennyPenny(
      color: Colors.white,
      fontSize: 24,
    );

    final halloweenActionButtonStyle = ActionButtonStyle(
      textStyle: halloweenTextStyle,
      iconColor: Colors.black,
      iconDecoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final halloweenMenuItemStyle = ActionButtonStyle(
      textStyle: halloweenMenuItemTextStyle,
      iconColor: Colors.white,
    );

    final halloweenMenuButtonStyle = ActionButtonStyle(
      textStyle: halloweenTextStyle,
      iconColor: Colors.orange,
      iconDecoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
    );

    return LlmChatViewStyle(
      backgroundColor: Colors.transparent,
      menuColor: Colors.grey.shade600,
      progressIndicatorColor: Colors.purple,
      suggestionStyle: SuggestionStyle(
        textStyle: halloweenTextStyle.copyWith(color: Colors.black),
        decoration: BoxDecoration(
          color: Colors.yellow,
          border: Border.all(color: Colors.orange),
        ),
      ),
      chatInputStyle: ChatInputStyle(
        backgroundColor:
            _animationController.isAnimating
                ? Colors.transparent
                : Colors.black,
        decoration: BoxDecoration(
          color: Colors.yellow,
          border: Border.all(color: Colors.orange),
        ),
        textStyle: halloweenTextStyle.copyWith(color: Colors.black),
        hintText: 'good evening...',
        hintStyle: halloweenTextStyle.copyWith(
          color: Colors.orange.withAlpha(128),
        ),
      ),
      userMessageStyle: UserMessageStyle(
        textStyle: halloweenTextStyle.copyWith(color: Colors.black),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade300, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(128),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
      llmMessageStyle: LlmMessageStyle(
        icon: Icons.sentiment_very_satisfied,
        iconColor: Colors.black,
        iconDecoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            topRight: Radius.zero,
            bottomRight: Radius.circular(8),
          ),
          border: Border.all(color: Colors.black),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepOrange.shade900,
              Colors.orange.shade800,
              Colors.purple.shade900,
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.zero,
            bottomLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(76),
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ],
        ),
        markdownStyle: MarkdownStyleSheet(
          p: halloweenTextStyle,
          listBullet: halloweenTextStyle,
        ),
      ),
      recordButtonStyle: halloweenActionButtonStyle,
      stopButtonStyle: halloweenActionButtonStyle,
      submitButtonStyle: halloweenActionButtonStyle,
      addButtonStyle: halloweenActionButtonStyle,
      attachFileButtonStyle: halloweenMenuItemStyle,
      cameraButtonStyle: halloweenMenuItemStyle,
      closeButtonStyle: halloweenActionButtonStyle,
      cancelButtonStyle: halloweenActionButtonStyle,
      closeMenuButtonStyle: halloweenActionButtonStyle,
      copyButtonStyle: halloweenMenuButtonStyle,
      editButtonStyle: halloweenMenuButtonStyle,
      galleryButtonStyle: halloweenMenuItemStyle,
      actionButtonBarDecoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      fileAttachmentStyle: FileAttachmentStyle(
        decoration: BoxDecoration(color: Colors.black),
        iconDecoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(8),
        ),
        filenameStyle: halloweenTextStyle,
        filetypeStyle: halloweenTextStyle.copyWith(
          color: Colors.green,
          fontSize: 18,
        ),
      ),
    );
  }
}
