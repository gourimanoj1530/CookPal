import 'recipe_ingredient.dart';

class Recipe {
  final int id;
  final String title;
  final String? description;
  final int cookingTime; // in minutes
  final int servings;
  final String difficultyLevel;
  final String? imageUrl;
  final String instructions;
  final DateTime createdAt;
  final int? userId;
  final double? averageRating;
  final int? ratingCount;
  final List<RecipeIngredient>? ingredients;

  Recipe({
    required this.id,
    required this.title,
    this.description,
    required this.cookingTime,
    required this.servings,
    required this.difficultyLevel,
    this.imageUrl,
    required this.instructions,
    required this.createdAt,
    this.userId,
    this.averageRating,
    this.ratingCount,
    this.ingredients,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      cookingTime: map['cooking_time'],
      servings: map['servings'],
      difficultyLevel: map['difficulty_level'],
      imageUrl: map['image_url'],
      instructions: map['instructions'],
      createdAt: DateTime.parse(map['created_at']),
      userId: map['user_id'],
      averageRating: map['average_rating']?.toDouble(),
      ratingCount: map['rating_count'],
      // ingredients field can be set after joining with ingredients table
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cooking_time': cookingTime,
      'servings': servings,
      'difficulty_level': difficultyLevel,
      'image_url': imageUrl,
      'instructions': instructions,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }

  String get difficultyColor {
    switch (difficultyLevel.toLowerCase()) {
      case 'easy':
        return '#4CAF50'; // Green
      case 'medium':
        return '#FF9800'; // Orange
      case 'hard':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  String get formattedCookingTime {
    if (cookingTime < 60) {
      return '${cookingTime}m';
    } else {
      int hours = cookingTime ~/ 60;
      int minutes = cookingTime % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }
}