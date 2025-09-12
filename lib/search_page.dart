import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/recipe_model.dart';
import 'recipe_detail_page.dart';

class SearchPage extends StatefulWidget {
  final int? userId;

  const SearchPage({super.key, this.userId});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _ingredientSearchResults = [];
  List<String> _selectedIngredients = [];
  List<Map<String, dynamic>> _availableIngredients = [];

  bool _isLoading = false;
  bool _isLoadingIngredients = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAvailableIngredients();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _ingredientController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableIngredients() async {
    try {
      final recipes = await _dbHelper.getAllRecipes();
      final Set<String> allIngredients = {};
      for (var recipe in recipes) {
        final ingredientsList = recipe['ingredients']?.toString().split(', ') ?? [];
        allIngredients.addAll(ingredientsList);
      }
      setState(() {
        _availableIngredients = allIngredients.map((name) => {'name': name}).toList();
      });
    } catch (e) {
      print('Error loading ingredients: $e');
    }
  }

  Future<void> _searchRecipes(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _dbHelper.searchRecipes(query.trim());
      setState(() {
        _searchResults = results
            .map((recipe) => {
          ...recipe.toMap(),
        })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error searching recipes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchByIngredients() async {
    if (_selectedIngredients.isEmpty) {
      setState(() {
        _ingredientSearchResults = [];
      });
      return;
    }

    setState(() {
      _isLoadingIngredients = true;
    });

    try {
      final results = await _dbHelper.getRecipesByIngredients(_selectedIngredients);
      setState(() {
        _ingredientSearchResults = results
            .map((recipe) => {
          ...recipe.toMap(),
        })
            .toList();
        _isLoadingIngredients = false;
      });
    } catch (e) {
      print('Error searching by ingredients: $e');
      setState(() {
        _isLoadingIngredients = false;
      });
    }
  }

  void _addIngredient(String ingredient) {
    if (!_selectedIngredients.contains(ingredient)) {
      setState(() {
        _selectedIngredients.add(ingredient);
      });
      _searchByIngredients();
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _selectedIngredients.remove(ingredient);
    });
    _searchByIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Search Recipes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Recipe Search'),
            Tab(text: 'By Ingredients'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecipeSearchTab(),
          _buildIngredientSearchTab(),
        ],
      ),
    );
  }

  Widget _buildRecipeSearchTab() {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search recipes by name...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _searchRecipes('');
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
            onChanged: _searchRecipes,
            textInputAction: TextInputAction.search,
          ),
        ),
        // Search results
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
              ? _buildEmptyState(
            icon: Icons.search,
            title: 'Search for recipes',
            subtitle: 'Type a recipe name to find delicious dishes',
          )
              : _buildRecipeList(_searchResults),
        ),
      ],
    );
  }

  Widget _buildIngredientSearchTab() {
    return Column(
      children: [
        // Ingredient input
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _ingredientController,
                decoration: InputDecoration(
                  hintText: 'Add ingredients you have...',
                  prefixIcon: const Icon(Icons.add),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _addIngredient(value.trim().toLowerCase());
                    _ingredientController.clear();
                  }
                },
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to add from common ingredients:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _availableIngredients.take(10).map((ingredient) {
                  final name = ingredient['name'] as String;
                  final isSelected = _selectedIngredients.contains(name);
                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        _removeIngredient(name);
                      } else {
                        _addIngredient(name);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        // Selected ingredients
        if (_selectedIngredients.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected ingredients:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _selectedIngredients.map((ingredient) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ingredient,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _removeIngredient(ingredient),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        // Ingredient search results
        Expanded(
          child: _isLoadingIngredients
              ? const Center(child: CircularProgressIndicator())
              : _selectedIngredients.isEmpty
              ? _buildEmptyState(
            icon: Icons.kitchen,
            title: 'Add ingredients',
            subtitle: 'Tell us what you have and we\'ll find matching recipes',
          )
              : _ingredientSearchResults.isEmpty
              ? _buildEmptyState(
            icon: Icons.sentiment_dissatisfied,
            title: 'No recipes found',
            subtitle: 'Try different ingredients or remove some',
          )
              : _buildRecipeList(_ingredientSearchResults),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList(List<Map<String, dynamic>> recipes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildRecipeCard(recipe),
        );
      },
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final cookingTime = _formatCookingTime(recipe['cookingTime']);
    final rating = recipe['average_rating']?.toDouble() ?? 0.0;
    final ratingCount = recipe['rating_count'] ?? 0;
    final matchedIngredients = recipe['matched_ingredients'] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailPage(
              recipeId: recipe['id'],
              userId: widget.userId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [Colors.orange.shade300, Colors.red.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  if (matchedIngredients > 0)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$matchedIngredients matches',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (recipe['difficulty_level'] != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(recipe['difficulty_level']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          recipe['difficulty_level'].toString().toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipe['title'] ?? 'Unknown Recipe',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (rating > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${rating.toStringAsFixed(1)} ($ratingCount)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Description
                  if (recipe['description'] != null)
                    Text(
                      recipe['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  // Meta info
                  Row(
                    children: [
                      if (cookingTime.isNotEmpty) ...[
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          cookingTime,
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (recipe['servings'] != null) ...[
                        Icon(Icons.people, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe['servings']} servings',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCookingTime(int? minutes) {
    if (minutes == null) return '';
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      return remainingMinutes > 0 ? '${hours}h ${remainingMinutes}m' : '${hours}h';
    }
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}