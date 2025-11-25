import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'auth_wrapper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedBottomIndex = 0;
  int selectedWaterCups = 1;
  int selectedDay = 21;
  int currentWeekStart = 20; // Початок поточного тижня
  String? expandedMeal; // null або 'Breakfast', 'Lunch', 'Dinner'
  Set<String> checkedMeals = {}; // Відзначені страви

  // Додаю змінні для календаря
  DateTime calendarStartDate = DateTime(2025, 9, 21);
  int calendarSelectedDay = 21;
  DateTime _selectedDate = DateTime.now();

  List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  List<String> weekDaysFull = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

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
                  [
                    {'id': 'breakfast_shakshouka', 'name': 'Shakshouka', 'calories': '150g/120 kcal', 'icon': '🍳'},
                    {'id': 'breakfast_salad', 'name': 'Salad', 'calories': '100g/60 kcal', 'icon': '🥗'},
                    {'id': 'breakfast_juice', 'name': 'Orange juice', 'calories': '250ml/80 kcal', 'icon': '🥤'},
                  ],
                ),
                const SizedBox(height: 12),
                _buildMealCard('Lunch time', '320/460 kcal', []),
                const SizedBox(height: 12),
                _buildMealCard('Dinner', '300/360 kcal', []),
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
        Container(
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
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Have a nice day!',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Olya Pelykh',
                style: TextStyle(
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
            onPressed: () {
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildMacroRow('Protein', '52/70'),
          const SizedBox(height: 16),
          _buildMacroRow('Fats', '52/70'),
          const SizedBox(height: 16),
          _buildMacroRow('Carbohydrates', '52/70'),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
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
                      onTap: () {
                        setState(() {
                          int newCount;
                          if (index == selectedWaterCups - 1) {
                            newCount = selectedWaterCups - 1;
                          } else {
                            newCount = index + 1;
                          }
                          selectedWaterCups = newCount;
                        });
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
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Column(
                children: [
                  Text(
                    DateFormat('E').format(date).substring(0, 1),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: isSelected ? Colors.black : Colors.black.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.grey[300] : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: isSelected ? Colors.black : Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMealCard(String title, String calories, List<Map<String, String>> items) {
    final isExpanded = expandedMeal == title;
    
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
                      calories,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isExpanded && items.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...items.map((item) {
                final mealId = item['id']!;
                final isChecked = checkedMeals.contains(mealId);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isChecked) {
                          checkedMeals.remove(mealId);
                        } else {
                          checkedMeals.add(mealId);
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              item['icon']!,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          item['calories']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isChecked ? Colors.black : Colors.white,
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: isChecked
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
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
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: selectedBottomIndex == 1 ? Colors.white : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.book_outlined,
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
