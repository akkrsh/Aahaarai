import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/food_item.dart';
import '../widgets/quantity_editor.dart';
import '../widgets/nutrition_card.dart';
import '../widgets/daily_summary.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<FoodItem> foodItems = [];

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    final rawItems =
        await ApiService.uploadFoodImage(File(image.path));

    setState(() {
      foodItems = rawItems
          .map<FoodItem>((e) => FoodItem.fromJson(e))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aahaar.AI")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Capture Food Image"),
            ),
            if (foodItems.isNotEmpty) ...[
              QuantityEditor(items: foodItems),
              NutritionCard(items: foodItems),
              DailySummary(items: foodItems),
            ],
          ],
        ),
      ),
    );
  }
}