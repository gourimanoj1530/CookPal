import 'package:flutter/material.dart';
import 'package:recipe_sharing_app/models/recipe_model.dart';
import 'database_helper.dart';
import 'login_page.dart';
import 'recipes_page.dart';
import 'search_page.dart';
import 'timer_page.dart';
import 'measurement_converter_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final int userId;

  const HomePage({super.key, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  String _userName = '';
  List<Recipe> _favoriteRecipes = [];
  List<Recipe> _randomRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadData();
    _dbHelper.debugPrintRecipes();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
    });
  }

  Future<void> _loadData() async {
    try {
      final favorites = await _dbHelper.getUserFavorites(widget.userId);
      final allRecipes = await _dbHelper.getRecipes();

      setState(() {
        _favoriteRecipes = favorites;
        _randomRecipes = allRecipes.take(6).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $_userName! 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(userId: widget.userId),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _randomRecipes.isEmpty
          ? _buildNoRecipesView()
          : _buildContent(),
    );
  }

  Widget _buildNoRecipesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No recipes found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some recipes to get started',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry Loading'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Recipes Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Featured Recipes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          _buildFeaturedRecipes(),

          // Quick Access Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Quick Access',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          _buildQuickAccessGrid(),

          // Favorites Section (if any)
          if (_favoriteRecipes.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Your Favorites',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            _buildFavoritesSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturedRecipes() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _randomRecipes.length,
        itemBuilder: (context, index) {
          final recipe = _randomRecipes[index];
          return _buildRecipeCard(recipe);
        },
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              'assets/images/${recipe.imageUrl}',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                color: Colors.grey[200],
                child: const Icon(Icons.restaurant_menu, size: 40),
              ),
            ),
          ),

          // Recipe Title
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              recipe.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _buildQuickAccessItem(
            Icons.restaurant_menu,
            'Recipes',
                () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipesPage(userId: widget.userId),
              ),
            ),
          ),
          _buildQuickAccessItem(
            Icons.timer,
            'Timer',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TimerPage()),
            ),
          ),
          _buildQuickAccessItem(
            Icons.swap_horiz,
            'Converter',
                () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MeasurementConverterPage(),
              ),
            ),
          ),
          _buildQuickAccessItem(
            Icons.favorite,
            'Favorites',
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipesPage(userId: widget.userId),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Showing all recipes - use filter for favorites'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = _favoriteRecipes[index];
          return _buildFavoriteCard(recipe);
        },
      ),
    );
  }

  Widget _buildFavoriteCard(Recipe recipe) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe Image with favorite badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  'assets/images/${recipe.imageUrl}',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.restaurant_menu, size: 30),
                  ),
                ),
              ),
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.favorite, color: Colors.red, size: 20),
              ),
            ],
          ),

          // Recipe Title
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              recipe.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}