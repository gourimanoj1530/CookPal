import 'package:recipe_sharing_app/models/recipe_model.dart';
import 'dart:convert';
import 'dart:html' as html;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static final String _storageKey = 'recipe_app_data';

  DatabaseHelper._init();

  // Initialize web storage with sample data
  Future<void> _initWebStorage() async {
    if (html.window.localStorage[_storageKey] == null) {
      final initialData = {
        'users': [
          {
            'id': 1,
            'name': 'Default User',
            'email': 'default@example.com',
            'password': 'password123'
          }
        ],
        'recipes': _getSampleRecipes(),
        'favorites': <Map<String, dynamic>>[]
      };
      html.window.localStorage[_storageKey] = jsonEncode(initialData);
    }
  }

  List<Map<String, dynamic>> _getSampleRecipes() {
    final now = DateTime.now().toIso8601String();

    return [
      {
        'id': 1,
        'title': 'Spaghetti Carbonara',
        'description': 'A classic Italian pasta dish with eggs, cheese, and pancetta',
        'ingredients': 'Spaghetti, Eggs, Parmesan Cheese, Pancetta, Black Pepper',
        'instructions': '1. Cook spaghetti\n2. Fry pancetta\n3. Mix eggs and cheese\n4. Combine everything',
        'tags': 'Italian, Pasta, Quick',
        'cookingTime': 30,
        'servings': 4,
        'userId': 1,
        'imageUrl': 'spaghetti.jpg',
        'createdAt': now,
      },
      {
        'id': 2,
        'title': 'Chocolate Chip Cookies',
        'description': 'Soft and chewy homemade chocolate chip cookies',
        'ingredients': 'Flour, Butter, Sugar, Eggs, Chocolate Chips, Vanilla',
        'instructions': '1. Mix dry ingredients\n2. Cream butter and sugar\n3. Add eggs and vanilla\n4. Bake at 350°F for 12 minutes',
        'tags': 'Dessert, Baking, Sweet',
        'cookingTime': 25,
        'servings': 24,
        'userId': 1,
        'imageUrl': 'cookies.jpg',
        'createdAt': now,
      },
      {
        'id': 3,
        'title': 'Vegetable Stir Fry',
        'description': 'Healthy and colorful vegetable stir fry with Asian flavors',
        'ingredients': 'Broccoli, Carrots, Bell Peppers, Soy Sauce, Garlic, Ginger',
        'instructions': '1. Chop vegetables\n2. Heat oil in wok\n3. Stir fry vegetables\n4. Add sauce and serve',
        'tags': 'Vegetarian, Healthy, Asian',
        'cookingTime': 15,
        'servings': 2,
        'userId': 1,
        'imageUrl': 'stirfry.jpg',
        'createdAt': now,
      },
    ];
  }

  // Get all data from localStorage
  Map<String, dynamic> _getData() {
    final dataString = html.window.localStorage[_storageKey];
    if (dataString == null) {
      return {};
    }
    return jsonDecode(dataString);
  }

  // Save data to localStorage
  void _saveData(Map<String, dynamic> data) {
    html.window.localStorage[_storageKey] = jsonEncode(data);
  }

  // Helper method to convert database row to Recipe object
  Recipe _mapToRecipe(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      ingredients: map['ingredients'].toString().split(', '),
      instructions: map['instructions'].toString().split('\n'),
      tags: map['tags']?.toString().split(', ') ?? [],
      cookingTime: map['cookingTime'] ?? 0,
      servings: map['servings'] ?? 1,
      userId: map['userId'] ?? 1,
      imageUrl: map['imageUrl'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Initialize the database (web storage)
  Future<void> initialize() async {
    await _initWebStorage();
  }

  // Get all recipes as Map (for compatibility)
  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    await _initWebStorage();
    final data = _getData();
    return List<Map<String, dynamic>>.from(data['recipes'] ?? []);
  }

  // Get all recipes as Recipe objects
  Future<List<Recipe>> getRecipes() async {
    final maps = await getAllRecipes();
    return maps.map((map) => _mapToRecipe(map)).toList();
  }

  // Get user favorites
  Future<List<Recipe>> getUserFavorites(int userId) async {
    await _initWebStorage();
    final data = _getData();
    final favorites = List<Map<String, dynamic>>.from(data['favorites'] ?? []);
    final recipes = List<Map<String, dynamic>>.from(data['recipes'] ?? []);

    final favoriteRecipeIds = favorites
        .where((fav) => fav['userId'] == userId)
        .map((fav) => fav['recipeId'])
        .toList();

    final favoriteRecipes = recipes
        .where((recipe) => favoriteRecipeIds.contains(recipe['id']))
        .toList();

    return favoriteRecipes.map((map) => _mapToRecipe(map)).toList();
  }

  // Debug print recipes
  Future<void> debugPrintRecipes() async {
    final recipes = await getAllRecipes();
    print('=== DATABASE DEBUG ===');
    print('Number of recipes in storage: ${recipes.length}');
    for (var recipe in recipes) {
      print('Recipe: ${recipe['title']} (ID: ${recipe['id']})');
    }
    print('=====================');
  }

  // User authentication methods
  Future<bool> checkUserCredentials(String email, String password) async {
    await _initWebStorage();
    final data = _getData();
    final users = List<Map<String, dynamic>>.from(data['users'] ?? []);

    return users.any((user) =>
    user['email'] == email && user['password'] == password);
  }

  Future<int?> getUserIdByEmail(String email) async {
    await _initWebStorage();
    final data = _getData();
    final users = List<Map<String, dynamic>>.from(data['users'] ?? []);

    final user = users.firstWhere(
            (user) => user['email'] == email,
        orElse: () => <String, dynamic>{});

    return user.isNotEmpty ? user['id'] as int? : null;
  }

  Future<int> insertUser(String name, String email, String password) async {
    await _initWebStorage();
    final data = _getData();
    final users = List<Map<String, dynamic>>.from(data['users'] ?? []);

    final newId = users.isEmpty ? 1 : users.map((u) => u['id'] as int).reduce((a, b) => a > b ? a : b) + 1;

    users.add({
      'id': newId,
      'name': name,
      'email': email,
      'password': password,
    });

    data['users'] = users;
    _saveData(data);

    return newId;
  }

  // Favorite methods
  Future<void> toggleFavorite(int userId, int recipeId) async {
    await _initWebStorage();
    final data = _getData();
    final favorites = List<Map<String, dynamic>>.from(data['favorites'] ?? []);

    final existingIndex = favorites.indexWhere((fav) =>
    fav['userId'] == userId && fav['recipeId'] == recipeId);

    if (existingIndex == -1) {
      // Add favorite
      final newId = favorites.isEmpty ? 1 : favorites.map((f) => f['id'] as int).reduce((a, b) => a > b ? a : b) + 1;
      favorites.add({
        'id': newId,
        'userId': userId,
        'recipeId': recipeId,
      });
    } else {
      // Remove favorite
      favorites.removeAt(existingIndex);
    }

    data['favorites'] = favorites;
    _saveData(data);
  }

  Future<bool> isFavorite(int userId, int recipeId) async {
    await _initWebStorage();
    final data = _getData();
    final favorites = List<Map<String, dynamic>>.from(data['favorites'] ?? []);

    return favorites.any((fav) =>
    fav['userId'] == userId && fav['recipeId'] == recipeId);
  }

  // Get recipe by ID
  Future<Recipe?> getRecipeById(int id) async {
    final recipes = await getAllRecipes();
    final recipeMap = recipes.firstWhere(
            (recipe) => recipe['id'] == id,
        orElse: () => <String, dynamic>{});

    return recipeMap.isNotEmpty ? _mapToRecipe(recipeMap) : null;
  }

  // Search recipes
  Future<List<Recipe>> searchRecipes(String query) async {
    final recipes = await getAllRecipes();
    final queryLower = query.toLowerCase();

    final filteredRecipes = recipes.where((recipe) {
      final title = recipe['title']?.toString().toLowerCase() ?? '';
      final description = recipe['description']?.toString().toLowerCase() ?? '';
      final ingredients = recipe['ingredients']?.toString().toLowerCase() ?? '';
      final tags = recipe['tags']?.toString().toLowerCase() ?? '';

      return title.contains(queryLower) ||
          description.contains(queryLower) ||
          ingredients.contains(queryLower) ||
          tags.contains(queryLower);
    }).toList();

    return filteredRecipes.map((map) => _mapToRecipe(map)).toList();
  }

  // Get recipes by ingredients
  Future<List<Recipe>> getRecipesByIngredients(List<String> ingredients) async {
    final recipes = await getAllRecipes();
    final ingredientsLower = ingredients.map((i) => i.toLowerCase()).toList();

    final filteredRecipes = recipes.where((recipe) {
      final recipeIngredients = recipe['ingredients']?.toString().toLowerCase() ?? '';

      return ingredientsLower.any((ingredient) =>
          recipeIngredients.contains(ingredient));
    }).toList();

    return filteredRecipes.map((map) => _mapToRecipe(map)).toList();
  }

  // Insert new recipe
  Future<int> insertRecipe(Recipe recipe) async {
    await _initWebStorage();
    final data = _getData();
    final recipes = List<Map<String, dynamic>>.from(data['recipes'] ?? []);

    final newId = recipes.isEmpty ? 1 : recipes.map((r) => r['id'] as int).reduce((a, b) => a > b ? a : b) + 1;

    recipes.add({
      'id': newId,
      'title': recipe.title,
      'description': recipe.description,
      'ingredients': recipe.ingredients.join(', '),
      'instructions': recipe.instructions.join('\n'),
      'tags': recipe.tags.join(', '),
      'cookingTime': recipe.cookingTime,
      'servings': recipe.servings,
      'userId': recipe.userId,
      'imageUrl': recipe.imageUrl,
      'createdAt': recipe.createdAt.toIso8601String(),
    });

    data['recipes'] = recipes;
    _saveData(data);

    return newId;
  }

  // Update recipe
  Future<int> updateRecipe(Recipe recipe) async {
    await _initWebStorage();
    final data = _getData();
    final recipes = List<Map<String, dynamic>>.from(data['recipes'] ?? []);

    final index = recipes.indexWhere((r) => r['id'] == recipe.id);
    if (index != -1) {
      recipes[index] = {
        'id': recipe.id,
        'title': recipe.title,
        'description': recipe.description,
        'ingredients': recipe.ingredients.join(', '),
        'instructions': recipe.instructions.join('\n'),
        'tags': recipe.tags.join(', '),
        'cookingTime': recipe.cookingTime,
        'servings': recipe.servings,
        'userId': recipe.userId,
        'imageUrl': recipe.imageUrl,
        'createdAt': recipe.createdAt.toIso8601String(),
      };

      data['recipes'] = recipes;
      _saveData(data);
      return 1;
    }
    return 0;
  }

  // Delete recipe
  Future<int> deleteRecipe(int id) async {
    await _initWebStorage();
    final data = _getData();
    final recipes = List<Map<String, dynamic>>.from(data['recipes'] ?? []);

    final initialLength = recipes.length;
    recipes.removeWhere((recipe) => recipe['id'] == id);

    if (recipes.length < initialLength) {
      data['recipes'] = recipes;
      _saveData(data);
      return 1;
    }
    return 0;
  }

  // Get recipes by tag
  Future<List<Recipe>> getRecipesByTag(String tag) async {
    final recipes = await getAllRecipes();
    final tagLower = tag.toLowerCase();

    final filteredRecipes = recipes.where((recipe) {
      final tags = recipe['tags']?.toString().toLowerCase() ?? '';
      return tags.contains(tagLower);
    }).toList();

    return filteredRecipes.map((map) => _mapToRecipe(map)).toList();
  }

  // Get recipes by user
  Future<List<Recipe>> getRecipesByUser(int userId) async {
    final recipes = await getAllRecipes();
    final filteredRecipes = recipes.where((recipe) => recipe['userId'] == userId).toList();
    return filteredRecipes.map((map) => _mapToRecipe(map)).toList();
  }
}