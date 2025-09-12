import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'recipe_detail_page.dart' as recipe_detail;
import 'models/recipe_model.dart';

class RecipesPage extends StatefulWidget {
  final int? userId;

  const RecipesPage({super.key, this.userId});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<Map<String, String>> _categories = [
    {'name': 'All', 'icon': '🍽️'},
    {'name': 'Indian', 'icon': '🍛'},
    {'name': 'Italian', 'icon': '🍝'},
    {'name': 'Chinese', 'icon': '🥢'},
    {'name': 'Thai', 'icon': '🌶️'},
    {'name': 'Mexican', 'icon': '🌮'},
    {'name': 'Drinks', 'icon': '🥤'},
    {'name': 'Desserts', 'icon': '🍰'},
    {'name': 'Quick Meals', 'icon': '⚡'},
    {'name': 'Healthy', 'icon': '🥗'},
    {'name': 'Snacks', 'icon': '🍿'},
    {'name': 'Sweet', 'icon': '🍯'},
    {'name': 'Spicy', 'icon': '🔥'},
    {'name': 'Comfort Food', 'icon': '🍲'},
    {'name': 'Fusion', 'icon': '🌍'},
  ];

  final Map<String, List<String>> keywords = {
    "indian": ["indian", "curry", "tandoor", "masala", "biryani", "dal", "naan"],
    "italian": ["italian", "pasta", "pizza", "risotto", "lasagna", "spaghetti"],
    "chinese": ["chinese", "stir fry", "wok", "soy sauce", "ginger", "garlic"],
    "mexican": ["mexican", "taco", "burrito", "quesadilla", "salsa", "guacamole"],
    "quick meals": ["quick", "easy", "fast", "minute", "instant", "simple"],
    "healthy": ["healthy", "light", "fresh", "lean", "low fat", "nutritious"],
    "spicy": ["spicy", "hot", "chili", "pepper", "jalapeno", "habanero"],
    "sweet": ["sweet", "sugar", "honey", "maple", "vanilla", "cinnamon"],
    "comfort food": ["comfort", "hearty", "creamy", "rich", "warm", "cozy"],
    "fusion": ["fusion", "modern", "contemporary", "twist", "inspired"],
    "thai": ["thai", "lemongrass", "coconut", "basil", "curry"],
    "drinks": ["drink", "juice", "smoothie", "tea", "coffee"],
    "desserts": ["dessert", "cake", "pie", "ice cream", "pudding"],
    "snacks": ["snack", "chips", "nacho", "crisp", "bites"],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadRecipes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    setState(() => _isLoading = true);
    try {
      final recipesData = await _dbHelper.getAllRecipes();
      final recipes = recipesData.map((data) => Recipe.fromMap(data)).toList();
      setState(() {
        _allRecipes = recipes;
        _filteredRecipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading recipes: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterRecipesByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredRecipes = _allRecipes;
      } else {
        final categoryKey = category.toLowerCase();
        final categoryKeywords =
            keywords[categoryKey] ?? [categoryKey];
        _filteredRecipes = _allRecipes.where((recipe) {
          final recipeTitle = recipe.title.toLowerCase();
          final recipeDescription = recipe.description.toLowerCase();
          final recipeTags = recipe.tags.map((t) => t.toLowerCase()).toList();

          return categoryKeywords.any((keyword) =>
          recipeTitle.contains(keyword) ||
              recipeDescription.contains(keyword) ||
              recipeTags.any((tag) => tag.contains(keyword))
          );
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Recipes'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories
              .map((category) => Tab(text: category['name']))
              .toList(),
          onTap: (index) =>
              _filterRecipesByCategory(_categories[index]['name']!),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredRecipes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No recipes found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.75,
        ),
        itemCount: _filteredRecipes.length,
        itemBuilder: (context, index) {
          final recipe = _filteredRecipes[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => recipe_detail.RecipeDetailPage(
                  recipeId: recipe.id,
                  userId: widget.userId,
                ),
              ),
            ),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/${recipe.imageUrl}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.restaurant_menu, size: 40),
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recipe.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}