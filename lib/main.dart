import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

void main() {
  runApp(const AahaarAIApp());
}

class AahaarAIApp extends StatelessWidget {
  const AahaarAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aahaar AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// --- 1. FIXED SPLASH SCREEN (Aligned & 5 Seconds) ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // CHANGED: Timer increased to 5 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // CHANGED: SizedBox(width: double.infinity) forces full width centering
        child: SizedBox(
          width: double.infinity, 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(), // Pushes content to the middle
              Icon(Icons.eco, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              Text(
                "Aahaar AI",
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.teal.shade800
                ),
              ),
              const Spacer(), // Pushes footer to the bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Text(
                  "Made with ❤️ at FoT",
                  style: TextStyle(
                    fontSize: 16, 
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Stats
  int _dailyCalories = 0;
  int _caloriesBurned = 0;
  int _calorieGoal = 2000;
  int _dailyProtein = 0;
  int _dailyCarbs = 0;
  int _dailyFat = 0;

  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  
  // Analysis Results
  String _dishName = "Scan a meal";
  String _verdict = "Healthy choices start here!";
  String _aiSuggestion = ""; // Stores the unique tip from AI
  int _scanCalories = 0;
  int _scanProtein = 0;
  int _scanCarbs = 0;
  int _scanFat = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- DATA MANAGEMENT ---
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyCalories = prefs.getInt('dailyCalories') ?? 0;
      _caloriesBurned = prefs.getInt('caloriesBurned') ?? 0;
      _calorieGoal = prefs.getInt('calorieGoal') ?? 2000;
      _dailyProtein = prefs.getInt('dailyProtein') ?? 0;
      _dailyCarbs = prefs.getInt('dailyCarbs') ?? 0;
      _dailyFat = prefs.getInt('dailyFat') ?? 0;
    });
  }

  Future<void> _saveMeal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyCalories += _scanCalories;
      _dailyProtein += _scanProtein;
      _dailyCarbs += _scanCarbs;
      _dailyFat += _scanFat;
      
      // Reset scan
      _image = null;
      _dishName = "Meal Added!";
      _verdict = "Great job tracking!";
      _aiSuggestion = ""; // Clear suggestion
      _scanCalories = 0;
    });
    
    await prefs.setInt('dailyCalories', _dailyCalories);
    await prefs.setInt('dailyProtein', _dailyProtein);
    await prefs.setInt('dailyCarbs', _dailyCarbs);
    await prefs.setInt('dailyFat', _dailyFat);
  }

  Future<void> _addBurnedCalories(int calories) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _caloriesBurned += calories;
    });
    await prefs.setInt('caloriesBurned', _caloriesBurned);
  }

  Future<void> _resetDay() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyCalories = 0;
      _caloriesBurned = 0;
      _dailyProtein = 0;
      _dailyCarbs = 0;
      _dailyFat = 0;
    });
    await prefs.remove('dailyCalories');
    await prefs.remove('caloriesBurned');
    await prefs.remove('dailyProtein');
    await prefs.remove('dailyCarbs');
    await prefs.remove('dailyFat');
  }

  // --- ACTIVITY DIALOG ---
  void _showActivityDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Add Fitness Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.directions_run, color: Colors.orange),
                title: const Text("Running (30 mins)"),
                subtitle: const Text("~300 kcal"),
                onTap: () { _addBurnedCalories(300); Navigator.pop(context); },
              ),
              ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.blue),
                title: const Text("Gym Workout (45 mins)"),
                subtitle: const Text("~200 kcal"),
                onTap: () { _addBurnedCalories(200); Navigator.pop(context); },
              ),
              ListTile(
                leading: const Icon(Icons.directions_walk, color: Colors.green),
                title: const Text("Walking (1 hour)"),
                subtitle: const Text("~150 kcal"),
                onTap: () { _addBurnedCalories(150); Navigator.pop(context); },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- CALCULATOR ---
  void _showCalculator() {
    TextEditingController weightCtrl = TextEditingController();
    TextEditingController heightCtrl = TextEditingController();
    TextEditingController ageCtrl = TextEditingController();
    String gender = "Male";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Calorie Calculator"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: "Weight (kg)"), keyboardType: TextInputType.number),
              TextField(controller: heightCtrl, decoration: const InputDecoration(labelText: "Height (cm)"), keyboardType: TextInputType.number),
              TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: "Age (years)"), keyboardType: TextInputType.number),
              DropdownButton<String>(
                value: gender,
                items: ["Male", "Female"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setDialogState(() => gender = val!),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                double w = double.tryParse(weightCtrl.text) ?? 0;
                double h = double.tryParse(heightCtrl.text) ?? 0;
                double a = double.tryParse(ageCtrl.text) ?? 0;
                double bmr = (10 * w) + (6.25 * h) - (5 * a) + ((gender == "Male") ? 5 : -161);
                int newGoal = (bmr * 1.55).round();
                
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('calorieGoal', newGoal);
                setState(() => _calorieGoal = newGoal);
                Navigator.pop(context);
              },
              child: const Text("Save Goal"),
            )
          ],
        ),
      ),
    );
  }

  // --- AI LOGIC ---
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() { _image = File(pickedFile.path); _isLoading = true; });
      await _analyzeImage(File(pickedFile.path));
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    // ---------------------------------------------------------
    // IMPORTANT: Setup for Android Studio Emulator
    // 10.0.2.2 = The Emulator's special way to reach localhost
    // ---------------------------------------------------------
    var uri = Uri.parse("http://192.168.1.6:8000/analyze"); 
    
    try {
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        _parseAIResponse(data['result']);
      } else {
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Connection Failed. Make sure python main.py is running!");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _parseAIResponse(String text) {
    setState(() {
      try {
        _dishName = _extractValue(text, "Dish:");
        _scanCalories = int.tryParse(_extractValue(text, "Calories:")) ?? 0;
        _scanProtein = int.tryParse(_extractValue(text, "Protein:")) ?? 0;
        _scanCarbs = int.tryParse(_extractValue(text, "Carbs:")) ?? 0;
        _scanFat = int.tryParse(_extractValue(text, "Fat:")) ?? 0;
        _verdict = _extractValue(text, "Verdict:");
        _aiSuggestion = _extractValue(text, "Suggestion:"); // NEW: Parses the unique tip
      } catch (e) {
        _dishName = "Error parsing result";
      }
    });
  }

  String _extractValue(String text, String key) {
    final regex = RegExp("$key\\s*(.*)");
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim() ?? "Unknown";
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    int netCalories = (_dailyCalories - _caloriesBurned).clamp(0, 10000);
    double progress = (netCalories / _calorieGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Apple style clean white
        elevation: 0,                  // Removes drop shadow
        scrolledUnderElevation: 0,     // Prevents color change when scrolling
        centerTitle: false,            // IMPORTANT: Aligns text to the left
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0), // Adds a little breathing room
          child: Text(
            "AahaarAI", // Apple Health usually says "Summary" here, or use "Aahaar AI"
            style: TextStyle(
              color: Colors.black,        // Stark black text
              fontSize: 32,               // Large size like iOS "Large Title"
              fontWeight: FontWeight.bold,// Thick weight
              letterSpacing: -0.5,        // Tight spacing for that modern look
              fontFamily: 'Roboto',       // Clean sans-serif (remove cursive)
            ),
          ),
        ),
        actions: [
          // Apple usually puts a profile icon or blue action button here
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              radius: 18,
              child: IconButton(
                icon: const Icon(Icons.refresh, size: 20, color: Colors.blue), // Blue is the Apple "Action" color
                onPressed: _resetDay,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- DASHBOARD ---
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircularPercentIndicator(
                        radius: 60.0,
                        lineWidth: 10.0,
                        percent: progress,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const Text("of Goal", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                        progressColor: Colors.teal,
                        backgroundColor: Colors.teal.shade100,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Net Calories", style: TextStyle(color: Colors.grey)),
                            Text("$netCalories / $_calorieGoal kcal", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            Text("Burned: $_caloriesBurned kcal", style: const TextStyle(fontSize: 14, color: Colors.red)),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: _showCalculator,
                                  icon: const Icon(Icons.calculate, size: 16),
                                  label: const Text("Goal"),
                                ),
                                TextButton.icon(
                                  onPressed: _showActivityDialog,
                                  icon: const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                                  label: const Text("Burn"),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              // --- NUTRIENTS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _nutrientCard("Protein", "${_dailyProtein}g", Colors.blue),
                  _nutrientCard("Carbs", "${_dailyCarbs}g", Colors.orange),
                  _nutrientCard("Fat", "${_dailyFat}g", Colors.red),
                ],
              ),
              const SizedBox(height: 10),

              // --- SCANNER SECTION ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    if (_image != null) 
                      ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_image!, height: 200, fit: BoxFit.cover))
                    else 
                      const Icon(Icons.camera_alt, size: 60, color: Colors.grey),
                    
                    const SizedBox(height: 10),
                    
                    if (_isLoading) const CircularProgressIndicator()
                    else Column(
                      children: [
                        Text(_dishName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(_verdict, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
                        
                        // --- 3. DYNAMIC SUGGESTION UI ---
                        if (_aiSuggestion.isNotEmpty && _aiSuggestion != "Unknown")
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb, color: Colors.blue.shade700),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _aiSuggestion, 
                                    style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.w500)
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 10),
                        if (_scanCalories > 0) ...[
                          Text("$_scanCalories kcal", style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold)),
                          Wrap(
                            spacing: 10,
                            children: [
                              Chip(label: Text("Prot: ${_scanProtein}g")),
                              Chip(label: Text("Carb: ${_scanCarbs}g")),
                              Chip(label: Text("Fat: ${_scanFat}g")),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _saveMeal,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                            icon: const Icon(Icons.add),
                            label: const Text("Add to Daily Log"),
                          )
                        ]
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Camera Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton.extended(
                    heroTag: "cam",
                    onPressed: () => _pickImage(ImageSource.camera),
                    label: const Text("Camera"),
                    icon: const Icon(Icons.camera),
                  ),
                  FloatingActionButton.extended(
                    heroTag: "gal",
                    onPressed: () => _pickImage(ImageSource.gallery),
                    label: const Text("Gallery"),
                    icon: const Icon(Icons.photo),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nutrientCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}