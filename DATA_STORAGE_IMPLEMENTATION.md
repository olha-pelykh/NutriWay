# Реалізація сховища даних користувача

## Опис реалізації

У застосунку NutriWay реалізовано **централізоване сховище даних користувача** з використанням паттерну **Provider** для управління станом та **SharedPreferences** для персистентного збереження даних.

## Архітектура

### 1. Provider Pattern (State Management)

Використовується пакет `provider: ^6.1.1` для управління станом автентифікації та даними користувача по всьому додатку.

```yaml
# pubspec.yaml
dependencies:
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  firebase_auth: ^4.17.8
```

### 2. AuthProvider - Центральний провайдер стану

**Файл:** `lib/providers/auth_provider.dart`

```dart
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  bool _hasCompletedOnboarding = false;
  String? _errorMessage;

  // Getters для доступу до стану
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  AuthProvider() {
    // Автоматичне відстеження змін автентифікації
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user == null) {
        _clearUserData();
      } else {
        _loadUserData();
      }
      notifyListeners();
    });
    _init();
  }
}
```

### 3. Збереження даних у SharedPreferences

#### Структура збережених даних:

| Ключ | Тип | Опис |
|------|-----|------|
| `onboarding_completed` | `bool` | Статус завершення онбордингу |

#### Методи роботи з даними:

**Завантаження даних:**
```dart
Future<void> _loadUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
    notifyListeners();
  } catch (e) {
    debugPrint('Error loading user data: $e');
  }
}
```

**Збереження даних:**
```dart
Future<void> setOnboardingCompleted() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    _hasCompletedOnboarding = true;
    notifyListeners();
  } catch (e) {
    debugPrint('Error setting onboarding completed: $e');
  }
}
```

**Очищення даних:**
```dart
Future<void> _clearUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_completed');
    _hasCompletedOnboarding = false;
    notifyListeners();
  } catch (e) {
    debugPrint('Error clearing user data: $e');
  }
}
```

### 4. Інтеграція з Firebase Authentication

Firebase Authentication автоматично зберігає та управляє токенами доступу. Provider інтегрується з Firebase Auth через `AuthService`:

```dart
// Слухач змін стану автентифікації
_authService.authStateChanges.listen((User? user) {
  _user = user;
  if (user == null) {
    _clearUserData();  // Очищення локальних даних при виході
  } else {
    _loadUserData();   // Завантаження даних при вході
  }
  notifyListeners();   // Оповіщення всіх слухачів про зміни
});
```

**Firebase автоматично:**
- Зберігає JWT токени у захищеному сховищі пристрою
- Оновлює токени при необхідності
- Управляє сесією користувача
- Забезпечує безпечне зберігання credentials

### 5. Використання Provider в додатку

**Ініціалізація в main.dart:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        home: const AuthWrapper(),
      ),
    );
  }
}
```

**Використання в екранах:**

```dart
// Отримання даних
final authProvider = Provider.of<AuthProvider>(context);
final user = authProvider.user;
final isLoading = authProvider.isLoading;

// Або з Consumer для автоматичного оновлення
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isLoading) {
      return CircularProgressIndicator();
    }
    return Text(authProvider.user?.email ?? 'No user');
  },
)

// Виклик методів
await authProvider.signIn(email: email, password: password);
await authProvider.setOnboardingCompleted();
await authProvider.signOut();
```

## Переваги реалізації

### 1. Централізоване управління станом
- Єдине джерело правди для стану автентифікації
- Автоматичне оновлення UI при змінах стану
- Відсутність prop drilling

### 2. Персистентність даних
- SharedPreferences для локального збереження
- Автоматичне відновлення стану при перезапуску додатку
- Безпечне зберігання через Firebase Auth

### 3. Реактивність
- Автоматичне відстеження змін автентифікації
- `notifyListeners()` оповіщає всі віджети про зміни
- Оптимізована перебудова тільки необхідних віджетів

### 4. Безпека
- Firebase Auth автоматично управляє токенами
- Токени зберігаються у захищеному сховищі
- Автоматичне оновлення токенів
- Захист від CSRF атак

### 5. Масштабованість
- Легко додати нові дані для збереження
- Можна додати інші провайдери (UserProvider, SettingsProvider)
- Модульна архітектура

## Приклад розширення

Додавання нових даних користувача:

```dart
class AuthProvider with ChangeNotifier {
  // Додаткові поля
  String? _userName;
  String? _userGoal;
  Map<String, dynamic>? _userPreferences;

  // Getters
  String? get userName => _userName;
  String? get userGoal => _userGoal;

  // Завантаження
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
    _userName = prefs.getString('user_name');
    _userGoal = prefs.getString('user_goal');
    
    // Завантаження складних даних через JSON
    final prefsJson = prefs.getString('user_preferences');
    if (prefsJson != null) {
      _userPreferences = jsonDecode(prefsJson);
    }
    
    notifyListeners();
  }

  // Збереження
  Future<void> saveUserProfile({
    required String name,
    required String goal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_goal', goal);
    
    _userName = name;
    _userGoal = goal;
    notifyListeners();
  }
}
```

## Висновок

Реалізована система управління даними користувача забезпечує:

✅ **Централізоване управління станом** через Provider  
✅ **Персистентне збереження** через SharedPreferences  
✅ **Автоматичне управління токенами** через Firebase Auth  
✅ **Реактивність** - автоматичне оновлення UI  
✅ **Безпеку** - захищене зберігання credentials  
✅ **Масштабованість** - легко розширювати функціонал  

Така архітектура є професійним стандартом для Flutter застосунків і забезпечує надійне та безпечне управління даними користувача.
