// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../data/recipe_data.dart';
import 'recipe_content_view.dart';

class RecipeView extends StatefulWidget {
  const RecipeView({
    required this.recipe,
    this.expanded = false,
    this.onExpansionChanged,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Recipe recipe;
  final bool expanded;
  @Deprecated('No longer used, kept for backward compatibility')
  final ValueChanged<bool>? onExpansionChanged;
  final Function() onEdit;
  final Function() onDelete;

  @override
  State<RecipeView> createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  Recipe get recipe => widget.recipe;
  bool get expanded => widget.expanded;
  VoidCallback get onEdit => widget.onEdit;
  VoidCallback get onDelete => widget.onDelete;
  
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${widget.recipe.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      widget.onDelete();
    }
  }



  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        ListTile(
          title: Text(recipe.title),
          subtitle: Text(recipe.description),
          onTap: () => context.goNamed('edit', pathParameters: {'recipe': recipe.id}),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context),
            tooltip: 'Delete Recipe',
          ),
        ),
        if (expanded) _buildExpandedContent(),
      ],
    ),
  );

  Widget _buildExpandedContent() => Column(
    children: [
      RecipeContentView(recipe: widget.recipe),
      _buildRelatedMedia(),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: OverflowBar(
          spacing: 8,
          alignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: widget.onDelete,
              child: const Text('Delete'),
            ),
            OutlinedButton(
              onPressed: widget.onEdit, 
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
    ],
  );

  Widget _buildRelatedMedia() {
    if (widget.recipe.relatedMedia.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Related Media',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: widget.recipe.relatedMedia.length,
            itemBuilder: (context, index) {
              final media = widget.recipe.relatedMedia[index];
              return _buildMediaCard(media);
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMediaCard(Map<String, dynamic> media) {
    return GestureDetector(
      onTap: () {
        final url = media['url'];
        if (url != null) {
          launchUrlString(url);
        }
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (media['imageUrl'] != null)
                Image.network(
                  media['imageUrl'],
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                      Container(
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (media['title'] != null)
                      Text(
                        media['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    if (media['source'] != null)
                      Text(
                        'Source: ${media['source']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
