import 'package:flutter/material.dart';
import '../models/food_item.dart';

class NutritionCard extends StatelessWidget {
  final List<FoodItem> items;

  const NutritionCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    double calories = 0, protein = 0, carbs = 0, fats = 0;

    for (var item in items) {
      calories += item.calories;
      protein += item.protein;
      carbs += item.carbs;
      fats += item.fats;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Calories: ${calories.toInt()} kcal"),
            Text("Protein: ${protein.toInt()} g"),
            Text("Carbs: ${carbs.toInt()} g"),
            Text("Fats: ${fats.toInt()} g"),
          ],
        ),
      ),
    );
  }
}