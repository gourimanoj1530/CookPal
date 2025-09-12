// home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 1; // Default to Cookbook tab in BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // You can add navigation or content swapping logic here
    // For now, just show a SnackBar as a placeholder
    final snackBars = [
      "Menu tapped - coming soon!",
      "Cookbook (Home) selected",
      "Tools tapped - coming soon!"
    ];
    if (index != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackBars[index])),
      );
    }
  }

  Widget _buildRecipeCard(String imageUrl, String title, String subtitle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Placeholder for recipe tap action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Selected: $title")),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    width: 120,
                    height: 120,
                    child: Center(child: CircularProgressIndicator(value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes! : null)),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Icon(Icons.timer, size: 16, color: Colors.orange),
                        SizedBox(width: 4),
                        Text('30 mins', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 16),
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text('4.5', style: TextStyle(fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _forYouTab() {
    // Sample data, ideally from backend or local storage
    final recipes = [
      {
        "image": "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80",
        "title": "Spaghetti Carbonara",
        "subtitle": "Classic Italian pasta recipe"
      },
      {
        "image": "https://images.unsplash.com/photo-1525755662778-989d0524087e?auto=format&fit=crop&w=800&q=80",
        "title": "Avocado Toast",
        "subtitle": "Simple & healthy breakfast"
      },
      {
        "image": "https://images.unsplash.com/photo-1506354666786-959d6d497f1a?auto=format&fit=crop&w=800&q=80",
        "title": "Berry Smoothie Bowl",
        "subtitle": "Fresh & refreshing treat"
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 80),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _buildRecipeCard(recipe["image"]!, recipe["title"]!, recipe["subtitle"]!);
      },
    );
  }

  Widget _savedRecipesTab() {
    // Placeholder for no saved recipes
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Saved Recipes',
            style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Save your favorite recipes to find them here later!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          )
        ],
      ),
    );
  }

  Widget _tryNewTab() {
    // Example "Try New" quick picks
    final tryNewRecipes = [
      {"icon": Icons.spa, "name": "Vegan Delights"},
      {"icon": Icons.local_pizza, "name": "Pizza Variations"},
      {"icon": Icons.icecream, "name": "Dessert Ideas"},
      {"icon": Icons.local_cafe, "name": "Smoothies & Drinks"},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        itemCount: tryNewRecipes.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,
            mainAxisSpacing: 20, crossAxisSpacing: 20,
            childAspectRatio: 1.2),
        itemBuilder: (context, index) {
          final item = tryNewRecipes[index];
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.orange.shade100,
              foregroundColor: Colors.deepOrange,
              elevation: 3,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Explore ${item['name']} recipes')),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'] as IconData, size: 48),
                const SizedBox(height: 12),
                Text(item['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('COOK PAL'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search tapped')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelColor: Colors.orange.shade200,
          tabs: const [
            Tab(text: 'For You'),
            Tab(text: 'Saved Recipes'),
            Tab(text: 'Try New'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _forYouTab(),
          _savedRecipesTab(),
          _tryNewTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey[600],
        elevation: 12,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Cookbook',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_dining),
            label: 'Tools',
          ),
        ],
      ),
      backgroundColor: Colors.orange.shade50,
    );
  }
}