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