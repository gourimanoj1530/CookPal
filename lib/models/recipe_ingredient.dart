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