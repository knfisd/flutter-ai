// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/recipe_data.dart';
import '../data/recipe_repository.dart';
import 'recipe_view.dart';

class RecipeListView extends StatefulWidget {
  final String searchText;

  const RecipeListView({super.key, required this.searchText});

  @override
  State<RecipeListView> createState() => _RecipeListViewState();
}

class _RecipeListViewState extends State<RecipeListView> {
  // No longer need to track expanded state since we're navigating on tap

  Iterable<Recipe> _filteredRecipes(Iterable<Recipe> recipes) =>
      recipes
          .where(
            (recipe) =>
                recipe.title.toLowerCase().contains(
                  widget.searchText.toLowerCase(),
                ) ||
                recipe.description.toLowerCase().contains(
                  widget.searchText.toLowerCase(),
                ) ||
                recipe.tags.any(
                  (tag) => tag.toLowerCase().contains(
                    widget.searchText.toLowerCase(),
                  ),
                ),
          )
          .toList()
        ..sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<Iterable<Recipe>?>(
        valueListenable: RecipeRepository.items,
        builder: (context, recipes, child) {
          if (recipes == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final displayedRecipes = _filteredRecipes(recipes).toList();
          return ListView.builder(
            itemCount: displayedRecipes.length,
            itemBuilder: (context, index) {
              final recipe = displayedRecipes[index];
              return RecipeView(
                key: ValueKey(recipe.id),
                recipe: recipe,
                expanded: false, // No longer used for expansion, just for showing actions
                onExpansionChanged: null, // No expansion changes to handle
                onEdit: () => _onEdit(recipe),
                onDelete: () => _onDelete(recipe),
              );
            },
          );
        },
      );

  void _onEdit(Recipe recipe) =>
      context.goNamed('edit', pathParameters: {'recipe': recipe.id});

  void _onDelete(Recipe recipe) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Recipe'),
            content: Text(
              'Are you sure you want to delete the recipe "${recipe.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (shouldDelete == true) await RecipeRepository.deleteRecipe(recipe);
  }
}
