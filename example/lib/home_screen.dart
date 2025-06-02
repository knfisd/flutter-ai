// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter AI Demos')),
      body: ListView(
        children: [
          _buildDemoTile(
            context,
            title: 'Simple Chat Demo',
            description: 'A basic chat interface using Gemini AI',
            route: '/chat',
          ),
          _buildDemoTile(
            context,
            title: 'Advanced Chat Demo',
            description: 'A more advanced chat interface with theming',
            route: '/demo',
          ),
          _buildDemoTile(
            context,
            title: 'Recipes App',
            description: 'A recipe management application',
            route: '/recipes',
          ),
        ],
      ),
    );
  }

  Widget _buildDemoTile(
    BuildContext context, {
    required String title,
    required String description,
    required String route,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => context.go(route),
    );
  }
}
