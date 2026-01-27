import 'package:flutter/material.dart';
import 'screens/dashboard.dart';


void main() {
runApp(const AahaarAI());
}


class AahaarAI extends StatelessWidget {
const AahaarAI({super.key});


@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'Aahaar.AI',
theme: ThemeData(primarySwatch: Colors.green),
home: const Dashboard(),
);
}
}