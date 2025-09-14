import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/recipe_model.dart';

class RecipeDetailPage extends StatefulWidget {
  final int recipeId;
  final int? userId;

  const RecipeDetailPage({super.key, required this.recipeId, this.userId});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late Future<Recipe?> _recipeFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadRecipeDetails();
    _checkFavoriteStatus();
  }

  void _loadRecipeDetails() {
    _recipeFuture = _dbHelper.getRecipeById(widget.recipeId);
  }

  Future<void> _checkFavoriteStatus() async {
    if (widget.userId != null) {
      final isFav = await _dbHelper.isFavorite(widget.userId!, widget.recipeId);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.userId != null) {
      await _dbHelper.toggleFavorite(widget.userId!, widget.recipeId);
      setState(() {
        _isFavorite = !_isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to save favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Recipe?>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Recipe not found'));
          }

          final recipe = snapshot.data!;
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(recipe),
              SliverList(
                delegate: SliverChildListDelegate([
                  _buildRecipeHeader(recipe),
                  _buildInfoCards(recipe),
                  _buildSectionTitle('Ingredients'),
                  _buildIngredientsList(recipe.ingredients),
                  _buildSectionTitle('Instructions'),
                  _buildInstructionsList(recipe.instructions),
                  const SizedBox(height: 32),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(Recipe recipe) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          recipe.title,
          style: const TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 10)]),
        ),
        background: Hero(
          tag: 'recipeImage-${recipe.id}',
          child: Image.asset(
            recipe.imageUrl, // Use DB field directly
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.restaurant_menu, size: 80),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
          onPressed: _toggleFavorite,
          color: Colors.white,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Add share functionality here if needed
          },
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildRecipeHeader(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        recipe.title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCards(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoCard(Icons.schedule, '${recipe.cookingTime} min', 'Time'),
          _buildInfoCard(Icons.people, '${recipe.servings}', 'Servings'),
          if (recipe.tags.isNotEmpty)
            _buildInfoCard(Icons.label, recipe.tags.join(', '), 'Tags'),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 95,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: Colors.deepOrangeAccent),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildIngredientsList(List<String> ingredients) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: ingredients.map((ingredient) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 18, color: Colors.deepOrangeAccent),
                const SizedBox(width: 8),
                Expanded(child: Text(ingredient, style: const TextStyle(fontSize: 16))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstructionsList(List<String> instructions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: List.generate(instructions.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.deepOrangeAccent,
                  child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(instructions[index], style: const TextStyle(fontSize: 16, height: 1.4))),
              ],
            ),
          );
        }),
      ),
    );
  }
}