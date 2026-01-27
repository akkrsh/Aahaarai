import 'package:flutter/material.dart';
import '../models/food_item.dart';

class QuantityEditor extends StatefulWidget {
  final List<FoodItem> items;

  const QuantityEditor({super.key, required this.items});

  @override
  State<QuantityEditor> createState() => _QuantityEditorState();
}

class _QuantityEditorState extends State<QuantityEditor> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.items.map((item) {
        return Card(
          child: ListTile(
            title: Text(item.name),
            subtitle: Slider(
              min: 0.5,
              max: 3,
              divisions: 5,
              value: item.userQuantity,
              label: "${item.userQuantity} ${item.unit}",
              onChanged: (value) {
                setState(() {
                  item.userQuantity = value;
                });
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}