import 'package:flutter/material.dart';
import 'account_settings_screen.dart';
import 'package:intl/intl.dart';
import 'add_meal_dialog.dart';
import 'create_recipe_screen.dart';
import 'recipes_screen.dart';
import 'auth_wrapper.dart';
import '/services/auth_service.dart';
import '/services/user_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    String protein = '';
    String fats = '';
    String carbs = '';
    String calories = '';
    String firstName = '';
    String lastName = '';
  final _authService = AuthService();
  int selectedBottomIndex = 0;
  int selectedDay = 21;
  int currentWeekStart = 20; 
  String? expandedMeal; 
  Set<String> checkedMeals = {}; 

  DateTime calendarStartDate = DateTime(2025, 9, 21);
  int calendarSelectedDay = 21;
  DateTime _selectedDate = DateTime.now();
  int selectedWaterCups = 1;
  List<Map<String, dynamic>> breakfast = [];
  List<Map<String, dynamic>> lunch = [];
  List<Map<String, dynamic>> dinner = [];
  List<Map<String, dynamic>> snacks = [];
  bool isLoadingLog = false;

  List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _loadLogForDate(_selectedDate);
    _loadUserMacros();
  }

  Future<void> _loadLogForDate(DateTime date) async {
    setState(() => isLoadingLog = true);
    final userDataService = UserDataService();
    final log = await userDataService.getDailyLog(date);
    if (log != null) {
      setState(() {
        selectedWaterCups = ((log['waterMl'] ?? 0) / 250).round();
        breakfast = List<Map<String, dynamic>>.from((log['breakfast'] ?? []).map((item) => item is Map ? Map<String, dynamic>.from(item) : {'name': item.toString()}));
        lunch = List<Map<String, dynamic>>.from((log['lunch'] ?? []).map((item) => item is Map ? Map<String, dynamic>.from(item) : {'name': item.toString()}));
        dinner = List<Map<String, dynamic>>.from((log['dinner'] ?? []).map((item) => item is Map ? Map<String, dynamic>.from(item) : {'name': item.toString()}));
        snacks = List<Map<String, dynamic>>.from((log['snacks'] ?? []).map((item) => item is Map ? Map<String, dynamic>.from(item) : {'name': item.toString()}));
      });
    } else {
      setState(() {
        selectedWaterCups = 0;
        breakfast = [];
        lunch = [];
        dinner = [];
        snacks = [];
      });
    }
    setState(() => isLoadingLog = false);

  }

  Future<void> _loadUserMacros() async {
    final userDataService = UserDataService();
    final data = await userDataService.getUserData();
    if (data != null) {
      setState(() {
        protein = data['protein']?.toString() ?? '';
        fats = data['fats']?.toString() ?? '';
        carbs = data['carbs']?.toString() ?? '';
        calories = data['calories']?.toString() ?? '';
        firstName = data['firstName']?.toString() ?? '';
        lastName = data['lastName']?.toString() ?? '';
      });
    }
  }

  Future<void> _saveLogForDate(DateTime date) async {
    final userDataService = UserDataService();
      await userDataService.saveDailyLog(
        date: date,
        waterMl: selectedWaterCups * 250,
        breakfast: [],
        lunch: [],
        dinner: [],
        snacks: [],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildMacrosCard(),
                const SizedBox(height: 20),
                _buildWaterTracker(),
                const SizedBox(height: 20),
                _buildCalendar(),
                const SizedBox(height: 20),
                _buildMealCard(
                  'Breakfast',
                  '320/460 kcal',
                  breakfast,
                  (meal) => _addMealDialog('Breakfast'),
                ),
                const SizedBox(height: 12),
                _buildMealCard(
                  'Lunch',
                  '320/460 kcal',
                  lunch,
                  (meal) => _addMealDialog('Lunch'),
                ),
                const SizedBox(height: 12),
                _buildMealCard(
                  'Dinner',
                  '300/360 kcal',
                  dinner,
                  (meal) => _addMealDialog('Dinner'),
                ),
                const SizedBox(height: 12),
                _buildMealCard(
                  'Snacks',
                  '150/200 kcal',
                  snacks,
                  (meal) => _addMealDialog('Snacks'),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
            );
            await _loadUserMacros();
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?img=12'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Have a nice day!',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                firstName.isNotEmpty && lastName.isNotEmpty
                    ? '$firstName $lastName'
                    : 'User',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.logout, color: Colors.black, size: 24),
            onPressed: () async {
              await _authService.signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthWrapper()),
                (route) => false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMacrosCard() {
    // Calculate totals from all meals
    final allMeals = [...breakfast, ...lunch, ...dinner, ...snacks];
    final totalCalories = allMeals.fold<double>(0, (sum, meal) => 
      sum + (double.tryParse(meal['calories']?.toString() ?? '0') ?? 0));
    final totalProtein = allMeals.fold<double>(0, (sum, meal) => 
      sum + (double.tryParse(meal['protein']?.toString() ?? '0') ?? 0));
    final totalFat = allMeals.fold<double>(0, (sum, meal) => 
      sum + (double.tryParse(meal['fat']?.toString() ?? '0') ?? 0));
    final totalCarb = allMeals.fold<double>(0, (sum, meal) => 
      sum + (double.tryParse(meal['carb']?.toString() ?? '0') ?? 0));
    
    // Target values from user profile
    final targetProtein = double.tryParse(protein) ?? 0;
    final targetFat = double.tryParse(fats) ?? 0;
    final targetCarb = double.tryParse(carbs) ?? 0;
    final targetCalories = double.tryParse(calories) ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Nutrition',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Josefin Sans',
                ),
              ),
              Text(
                '${totalCalories.toStringAsFixed(0)}/${targetCalories.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Josefin Sans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMacroRow(
            'Protein', 
            '${totalProtein.toStringAsFixed(1)}g', 
            '${targetProtein.toStringAsFixed(0)}g',
            totalProtein / (targetProtein > 0 ? targetProtein : 1),
          ),
          const SizedBox(height: 16),
          _buildMacroRow(
            'Fat', 
            '${totalFat.toStringAsFixed(1)}g', 
            '${targetFat.toStringAsFixed(0)}g',
            totalFat / (targetFat > 0 ? targetFat : 1),
          ),
          const SizedBox(height: 16),
          _buildMacroRow(
            'Carbs', 
            '${totalCarb.toStringAsFixed(1)}g', 
            '${targetCarb.toStringAsFixed(0)}g',
            totalCarb / (targetCarb > 0 ? targetCarb : 1),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, String current, String target, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontFamily: 'Josefin Sans',
              ),
            ),
            Text(
              '$current / $target',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: 'Josefin Sans',
              ),
            ),
          ],
        ),

      ],
    );
  }

  Widget _buildWaterTracker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    bool isFilled = index < selectedWaterCups;
                    return InkWell(
                      onTap: () async {
                        setState(() {
                          int newCount;
                          if (index == selectedWaterCups - 1) {
                            newCount = selectedWaterCups - 1;
                          } else {
                            newCount = index + 1;
                          }
                          selectedWaterCups = newCount;
                        });
                        await _saveLogForDate(_selectedDate);
                      },
                      child: Icon(
                        isFilled ? Icons.local_drink : Icons.local_drink_outlined,
                        size: 30,
                        color: isFilled ? Colors.blue : Colors.grey[300],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '${selectedWaterCups > 10 ? 10 : selectedWaterCups}/10 cups',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${(selectedWaterCups * 0.25).toStringAsFixed(2)} L)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
                if (isLoadingLog)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            '💧',
            style: TextStyle(
              fontSize: 80,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    DateTime startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(_selectedDate),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 7));
                    });
                  },
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final date = startOfWeek.add(Duration(days: index));
            final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month && date.year == _selectedDate.year;
            return GestureDetector(
              onTap: () async {
                setState(() {
                  _selectedDate = date;
                });
                await _loadLogForDate(date);
              },
              child: Container(
                width: 40,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[100] : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weekDays[index],
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.blue : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        color: isSelected ? Colors.blue : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMealCard(String title, String calories, List<Map<String, dynamic>> items, Function(String) onAddMeal) {
    final isExpanded = expandedMeal == title;
    final totalCals = items.fold<double>(0, (sum, item) => sum + (double.tryParse(item['calories']?.toString() ?? '0') ?? 0));
    
    return GestureDetector(
      onTap: () {
        setState(() {
          expandedMeal = isExpanded ? null : title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'Josefin Sans',
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.bolt,
                      color: Colors.black,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${totalCals.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: 'Josefin Sans',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final meal = entry.value;
                final imageUrl = meal['imageUrl'] as String?;
                final hasImage = imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http');
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasImage) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 30),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      meal['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontFamily: 'Josefin Sans',
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${meal['weight']}g',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontFamily: 'Josefin Sans',
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20, color: Colors.red),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () async {
                                      setState(() {
                                        items.removeAt(index);
                                      });
                                      final userDataService = UserDataService();
                                      await userDataService.saveDailyLog(
                                        date: _selectedDate,
                                        waterMl: selectedWaterCups * 250,
                                        breakfast: breakfast,
                                        lunch: lunch,
                                        dinner: dinner,
                                        snacks: snacks,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildMacroInfo('Cal', meal['calories'] ?? '0'),
                                  _buildMacroInfo('Protein', '${meal['protein'] ?? '0'}g'),
                                  _buildMacroInfo('Fat', '${meal['fat'] ?? '0'}g'),
                                  _buildMacroInfo('Carbs', '${meal['carb'] ?? '0'}g'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => onAddMeal(title),
                child: const Text(
                  'Add meal +',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addMealDialog(String mealType) {
    showDialog(
      context: context,
      builder: (context) {
        return AddMealDialog(
          mealType: mealType,
          onRecipeSelected: (recipe) async {
            final weight = recipe['weight'] ?? 100.0;
            final multiplier = weight / 100.0;
            
            final mealData = {
              'name': recipe['name'],
              'weight': weight,
              'calories': ((double.tryParse(recipe['calories']?.toString() ?? '0') ?? 0) * multiplier).toStringAsFixed(0),
              'protein': ((double.tryParse(recipe['protein']?.toString() ?? '0') ?? 0) * multiplier).toStringAsFixed(1),
              'fat': ((double.tryParse(recipe['fat']?.toString() ?? '0') ?? 0) * multiplier).toStringAsFixed(1),
              'carb': ((double.tryParse(recipe['carb']?.toString() ?? '0') ?? 0) * multiplier).toStringAsFixed(1),
              'imageUrl': recipe['imageUrl'] ?? '',
            };
            
            setState(() {
              if (mealType == 'Breakfast') breakfast.add(mealData);
              if (mealType == 'Lunch') lunch.add(mealData);
              if (mealType == 'Dinner') dinner.add(mealData);
              if (mealType == 'Snacks') snacks.add(mealData);
            });
            // Save to Firestore
            final userDataService = UserDataService();
            await userDataService.saveDailyLog(
              date: _selectedDate,
              waterMl: selectedWaterCups * 250,
              breakfast: breakfast,
              lunch: lunch,
              dinner: dinner,
              snacks: snacks,
            );
          },
          onCreateRecipe: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CreateRecipeScreen()),
            );
          },
        );
      },
    );
  }

  Widget _buildMacroInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: 'Josefin Sans',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Josefin Sans',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 20,
            child: Container(
              width: 180,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D0D0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedBottomIndex = 0;
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: selectedBottomIndex == 0 ? Colors.white : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.home,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedBottomIndex = 1;
                      });
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RecipesScreen()),
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: selectedBottomIndex == 1 ? Colors.white : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
