class Recipe {
  final int id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tags;
  final int cookingTime;
  final int servings;
  final int userId;
  final String imageUrl;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.tags,
    required this.cookingTime,
    required this.servings,
    required this.userId,
    required this.imageUrl,
    required this.createdAt,
  });

  // Factory for localStorage (string fields)
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      ingredients: map['ingredients'] is List
          ? List<String>.from(map['ingredients'])
          : map['ingredients'].toString().split(', ').where((e) => e.isNotEmpty).toList(),
      instructions: map['instructions'] is List
          ? List<String>.from(map['instructions'])
          : map['instructions'].toString().split('\n').where((e) => e.isNotEmpty).toList(),
      tags: map['tags'] is List
          ? List<String>.from(map['tags'])
          : map['tags'] == null
          ? []
          : map['tags'].toString().split(', ').where((e) => e.isNotEmpty).toList(),
      cookingTime: map['cookingTime'] is int
          ? map['cookingTime']
          : int.tryParse(map['cookingTime'].toString()) ?? 0,
      servings: map['servings'] is int
          ? map['servings']
          : int.tryParse(map['servings'].toString()) ?? 1,
      userId: map['userId'] is int
          ? map['userId']
          : int.tryParse(map['userId'].toString()) ?? 1,
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.parse(map['createdAt']),
    );
  }

  // For converting to JSON (for localStorage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients.join(', '),
      'instructions': instructions.join('\n'),
      'tags': tags.join(', '),
      'cookingTime': cookingTime,
      'servings': servings,
      'userId': userId,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}