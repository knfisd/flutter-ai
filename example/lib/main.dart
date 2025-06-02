// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:go_router/go_router.dart';

// from `flutterfire config`: https://firebase.google.com/docs/flutter/setup
import 'firebase_options.dart';
import 'home_screen.dart';

// Import demo pages
import 'demo/demo.dart' as demo_app;
import 'recipes/recipes.dart' as recipes_app;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize recipes app if needed
  try {
    // Initialize recipes app without using the void return value
    await Future.microtask(() => recipes_app.main());
  } catch (e) {
    debugPrint('Error initializing recipes app: $e');
  }

  runApp(App());
}

class App extends StatelessWidget {
  static const title = 'Flutter AI Demos';

  late final GoRouter _router;

  App({super.key}) {
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => HomeScreen()),
        GoRoute(path: '/chat', builder: (context, state) => _ChatPage()),
        GoRoute(path: '/demo', builder: (context, state) => demo_app.App()),
        GoRoute(
          path: '/recipes',
          builder: (context, state) => recipes_app.App(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _ChatPage extends StatelessWidget {
  const _ChatPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Simple Chat Demo'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/'),
      ),
    ),
    body: LlmChatView(
      provider: FirebaseProvider(
        model: FirebaseAI.googleAI().generativeModel(model: 'gemini-2.0-flash'),
      ),
    ),
  );
}
