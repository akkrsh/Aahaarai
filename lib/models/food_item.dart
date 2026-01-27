class FoodItem {
  String name;
  String unit;
  double userQuantity;
  Map<String, dynamic> nutritionPerUnit;

  FoodItem({
    required this.name,
    required this.unit,
    required this.userQuantity,
    required this.nutritionPerUnit,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      unit: json['unit'],
      userQuantity: (json['quantity'] ?? 1).toDouble(),
      nutritionPerUnit: json['nutrition_per_unit'],
    );
  }

  double get calories => userQuantity * nutritionPerUnit['calories'];
  double get protein => userQuantity * nutritionPerUnit['protein'];
  double get carbs => userQuantity * nutritionPerUnit['carbs'];
  double get fats => userQuantity * nutritionPerUnit['fats'];
}