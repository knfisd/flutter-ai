// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import '../data/recipe_data.dart';
import '../data/recipe_repository.dart';

class EditRecipePage extends StatefulWidget {
  const EditRecipePage({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _MediaResult {
  final String? imageUrl;
  final String? title;
  final String? source;
  final String? url;

  _MediaResult({
    this.imageUrl,
    this.title,
    this.source,
    this.url,
  });
}

class _EditRecipePageState extends State<EditRecipePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _ingredientsController;
  late final TextEditingController _instructionsController;
  
  bool _isSearching = false;
  List<_MediaResult> _searchResults = [];
  String? _error;


  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.recipe.title);
    _descriptionController = TextEditingController(
      text: widget.recipe.description,
    );
    _ingredientsController = TextEditingController(
      text: widget.recipe.ingredients.join('\n'),
    );
    _instructionsController = TextEditingController(
      text: widget.recipe.instructions.join('\n'),
    );
    
    // Load any existing related media
    if (widget.recipe.relatedMedia.isNotEmpty) {
      _searchResults = widget.recipe.relatedMedia.map((media) => _MediaResult(
        imageUrl: media['imageUrl'],
        title: media['title'],
        source: media['source'],
        url: media['url'],
      )).toList();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  bool get _isNewRecipe => widget.recipe.id == RecipeRepository.newRecipeID;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${_isNewRecipe ? "Add" : "Edit"} Recipe')),
    body: Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter a name for your recipe...',
              ),
              validator:
                  (value) =>
                      (value == null || value.isEmpty)
                          ? 'Recipe title is requires'
                          : null,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'In a few words, describe your recipe...',
              ),
              maxLines: null,
            ),
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: 'Ingredients🍎 (one per line)',
                hintText: 'e.g., 2 cups flour\n1 tsp salt\n1 cup sugar',
              ),
              maxLines: null,
            ),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions🥧 (one per line)',
                hintText: 'e.g., Mix ingredients\nBake for 30 minutes',
              ),
              maxLines: null,
            ),
            const SizedBox(height: 16),
            OverflowBar(
              spacing: 16,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome, size: 20),
                  label: const Text('Find Related Media'),
                  onPressed: _isSearching ? null : () {
                    if (_titleController.text.isNotEmpty) {
                      _searchForMedia();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a recipe title first')),
                      );
                    }
                  },
                ),
                OutlinedButton(
                  onPressed: _onDone,
                  child: const Text('Done'),
                ),
              ],
            ),
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (_searchResults.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Related Media',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) => 
                            SizedBox(width: 160, child: _buildMediaResult(_searchResults[index])),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );

  void _onDone() {
    if (!_formKey.currentState!.validate()) return;

    // Convert search results to a list of maps for storage
    final mediaList = _searchResults.map((result) => {
      'imageUrl': result.imageUrl,
      'title': result.title,
      'source': result.source,
      'url': result.url,
    }).toList();

    final recipe = Recipe(
      id: _isNewRecipe ? const Uuid().v4() : widget.recipe.id,
      title: _titleController.text,
      description: _descriptionController.text,
      ingredients: _ingredientsController.text.split('\n'),
      instructions: _instructionsController.text.split('\n'),
      relatedMedia: mediaList,
      tags: widget.recipe.tags,
      notes: widget.recipe.notes,
    );

    if (_isNewRecipe) {
      RecipeRepository.addNewRecipe(recipe);
    } else {
      RecipeRepository.updateRecipe(recipe);
    }

    if (context.mounted) context.goNamed('home');
  }

  Future<void> _searchForMedia() async {
    if (_isSearching) return;
    
    setState(() {
      _isSearching = true;
      _searchResults = [];
      _error = null;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data - in a real app, you would call an actual API here
      // For example: Google Custom Search API, Unsplash API, or your own backend
      final mockResults = [
        _MediaResult(
          imageUrl: 'https://source.unsplash.com/200x200/?${Uri.encodeComponent(_titleController.text)}',
          title: '${_titleController.text} Image',
          source: 'Unsplash',
          url: 'https://unsplash.com/s/photos/${Uri.encodeComponent(_titleController.text)}',
        ),
        _MediaResult(
          imageUrl: 'https://source.unsplash.com/200x200/?${Uri.encodeComponent(_titleController.text.split(' ').first)}',
          title: 'Related to ${_titleController.text.split(' ').first}',
          source: 'Unsplash',
          url: 'https://unsplash.com/s/photos/${Uri.encodeComponent(_titleController.text.split(' ').first)}',
        ),
      ];

      setState(() {
        _searchResults = mockResults;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load media. Please try again.';
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Widget _buildMediaResult(_MediaResult result) {
    return GestureDetector(
      onTap: () {
        if (result.url != null) {
          launchUrlString(result.url!);
        }
      },
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (result.imageUrl != null)
              Image.network(
                result.imageUrl!,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.broken_image, size: 60),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (result.title != null)
                    Text(
                      result.title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  if (result.source != null)
                    Text(
                      'Source: ${result.source!}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _onMagic and _wrapText methods have been removed as they're no longer used
}
