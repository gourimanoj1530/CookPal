import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/recipe_model.dart';


class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: DatabaseHelper.instance.fetchAllRecipes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final recipes = snapshot.data!;
        return ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return ListTile(
              leading: Image.asset(recipe.imageUrl, width: 80, errorBuilder: (_, __, ___) =>
                  Icon(Icons.broken_image) // fallback if not found
                ),
              title: Text(recipe.title),
              subtitle: Text(recipe.ingredients.join(', '), maxLines: 2, overflow: TextOverflow.ellipsis),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(recipe: recipe),
                ));
              },
            );
          },
        );
      }
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(recipe.imageUrl, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.broken_image)), 
            SizedBox(height: 16),
            Text("Ingredients", style: Theme.of(context).textTheme.titleLarge
),
            Text(recipe.ingredients.join(', ')),
            SizedBox(height: 16),
            Text("Instructions", style: Theme.of(context).textTheme.titleLarge
),
            Text(recipe.instructions.join(', ')),
          ],
        ),
      ),
    );
  }
}
