import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildContent(),
          _buildImage(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            recipe.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Icon(
            Icons.close,
            color: Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        recipe.description,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
          height: 1.4,
        ),
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(recipe.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}