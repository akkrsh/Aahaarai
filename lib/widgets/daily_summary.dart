import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';

class DailySummary extends StatefulWidget {
  final List<FoodItem> items;

  const DailySummary({super.key, required this.items});

  @override
  State<DailySummary> createState() => _DailySummaryState();
}

class _DailySummaryState extends State<DailySummary> {
  Map<String, dynamic>? summary;

  Future<void> fetchSummary() async {
    summary = await ApiService.getDailySummary();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: fetchSummary,
          child: const Text("Get Daily Summary"),
        ),
        if (summary != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              summary!['suggestion'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}