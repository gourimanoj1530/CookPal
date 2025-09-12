// models/user.dart
class User {
  final int id;
  final String email;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

// models/recipe.dart
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

// models/ingredient.dart
class Ingredient {
  final int id;
  final String name;
  final String? category;

  Ingredient({
    required this.id,
    required this.name,
    this.category,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'],
      name: map['name'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
    };
  }
}

// models/recipe_ingredient.dart
class RecipeIngredient {
  final int id;
  final int recipeId;
  final int ingredientId;
  final double? quantity;
  final String? unit;
  final String? ingredientName;

  RecipeIngredient({
    required this.id,
    required this.recipeId,
    required this.ingredientId,
    this.quantity,
    this.unit,
    this.ingredientName,
  });

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      id: map['id'] ?? 0,
      recipeId: map['recipe_id'] ?? 0,
      ingredientId: map['ingredient_id'] ?? 0,
      quantity: map['quantity']?.toDouble(),
      unit: map['unit'],
      ingredientName: map['name'], // from joined query
    );
  }

  String get displayText {
    String text = ingredientName ?? 'Unknown ingredient';
    if (quantity != null && unit != null) {
      // Format quantity nicely
      String quantityStr = quantity! % 1 == 0
          ? quantity!.toInt().toString()
          : quantity!.toString();
      text = '$quantityStr $unit $text';
    } else if (quantity != null) {
      String quantityStr = quantity! % 1 == 0
          ? quantity!.toInt().toString()
          : quantity!.toString();
      text = '$quantityStr $text';
    }
    return text;
  }
}

// models/rating.dart
class Rating {
  final int id;
  final int userId;
  final int recipeId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? userEmail;

  Rating({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userEmail,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'],
      userId: map['user_id'],
      recipeId: map['recipe_id'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: DateTime.parse(map['created_at']),
      userEmail: map['email'], // from joined query
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'recipe_id': recipeId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// models/cooking_timer.dart
class CookingTimer {
  final int id;
  final String name;
  final int durationInSeconds;
  final DateTime startTime;
  bool isRunning;
  bool isCompleted;

  CookingTimer({
    required this.id,
    required this.name,
    required this.durationInSeconds,
    required this.startTime,
    this.isRunning = false,
    this.isCompleted = false,
  });

  int get remainingSeconds {
    if (isCompleted) return 0;

    final elapsed = DateTime.now().difference(startTime).inSeconds;
    final remaining = durationInSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  String get formattedTime {
    int seconds = remainingSeconds;
    int minutes = seconds ~/ 60;
    int hours = minutes ~/ 60;

    seconds = seconds % 60;
    minutes = minutes % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  double get progress {
    if (durationInSeconds == 0) return 1.0;
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    final progress = elapsed / durationInSeconds;
    return progress.clamp(0.0, 1.0);
  }
}

// models/measurement_conversion.dart
class MeasurementConversion {
  static const Map<String, Map<String, double>> _conversions = {
    // Volume conversions (to ml)
    'volume': {
      'ml': 1.0,
      'l': 1000.0,
      'tsp': 5.0,
      'tbsp': 15.0,
      'cup': 240.0,
      'fl oz': 30.0,
      'pint': 473.0,
      'quart': 946.0,
      'gallon': 3785.0,
    },
    // Weight conversions (to grams)
    'weight': {
      'g': 1.0,
      'kg': 1000.0,
      'oz': 28.35,
      'lb': 453.6,
      'mg': 0.001,
    },
    // Temperature conversions
    'temperature': {
      'celsius': 1.0,
      'fahrenheit': 1.0, // Special handling needed
      'kelvin': 1.0, // Special handling needed
    }
  };

  static double? convert(double amount, String fromUnit, String toUnit) {
    fromUnit = fromUnit.toLowerCase();
    toUnit = toUnit.toLowerCase();

    if (fromUnit == toUnit) return amount;

    // Check volume conversions
    if (_conversions['volume']!.containsKey(fromUnit) &&
        _conversions['volume']!.containsKey(toUnit)) {
      double mlValue = amount * _conversions['volume']![fromUnit]!;
      return mlValue / _conversions['volume']![toUnit]!;
    }

    // Check weight conversions
    if (_conversions['weight']!.containsKey(fromUnit) &&
        _conversions['weight']!.containsKey(toUnit)) {
      double gramValue = amount * _conversions['weight']![fromUnit]!;
      return gramValue / _conversions['weight']![toUnit]!;
    }

    // Temperature conversions
    if (fromUnit == 'celsius' && toUnit == 'fahrenheit') {
      return (amount * 9/5) + 32;
    }
    if (fromUnit == 'fahrenheit' && toUnit == 'celsius') {
      return (amount - 32) * 5/9;
    }
    if (fromUnit == 'celsius' && toUnit == 'kelvin') {
      return amount + 273.15;
    }
    if (fromUnit == 'kelvin' && toUnit == 'celsius') {
      return amount - 273.15;
    }

    return null; // No conversion found
  }

  static List<String> getVolumeUnits() {
    return _conversions['volume']!.keys.toList();
  }

  static List<String> getWeightUnits() {
    return _conversions['weight']!.keys.toList();
  }

  static List<String> getTemperatureUnits() {
    return ['celsius', 'fahrenheit', 'kelvin'];
  }

  static String getUnitCategory(String unit) {
    unit = unit.toLowerCase();
    if (_conversions['volume']!.containsKey(unit)) return 'volume';
    if (_conversions['weight']!.containsKey(unit)) return 'weight';
    if (_conversions['temperature']!.containsKey(unit)) return 'temperature';
    return 'unknown';
  }
}