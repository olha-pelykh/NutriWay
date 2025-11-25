# Firebase Authentication Setup

## Налаштування Firebase Authentication

Цей додаток використовує Firebase Authentication для реєстрації та входу користувачів через email/password.

### Функціонал

✅ **Реєстрація користувачів** з email та password
✅ **Вхід користувачів** з email та password
✅ **Верифікація email** після реєстрації
✅ **Скидання паролю** через email
✅ **Повторна відправка** листа з верифікацією
✅ **Автоматична перевірка** статусу автентифікації
✅ **Вихід з системи**

### Налаштування Firebase Console

1. **Перейдіть у Firebase Console**: https://console.firebase.google.com/
2. **Виберіть ваш проект** (або створіть новий)
3. **Увімкніть Authentication:**
   - У бічному меню виберіть **Authentication**
   - Перейдіть на вкладку **Sign-in method**
   - Натисніть **Email/Password**
   - Увімкніть **Email/Password** (перший перемикач)
   - Натисніть **Save**

### Структура проекту

```
lib/
├── services/
│   └── auth_service.dart          # Сервіс автентифікації Firebase
├── screens/
│   ├── auth_wrapper.dart          # Wrapper для управління станом автентифікації
│   ├── register_screen.dart       # Екран реєстрації
│   ├── login_screen.dart          # Екран входу
│   ├── forgot_password_screen.dart # Екран скидання паролю
│   └── home_screen.dart           # Домашній екран
└── main.dart                      # Ініціалізація Firebase
```

### Опис функціоналу

#### AuthService (`lib/services/auth_service.dart`)

Клас для роботи з Firebase Authentication:

- `registerWithEmailPassword()` - Реєстрація нового користувача
- `signInWithEmailPassword()` - Вхід користувача
- `signOut()` - Вихід з системи
- `sendPasswordResetEmail()` - Відправка листа для скидання паролю
- `resendEmailVerification()` - Повторна відправка листа з верифікацією
- `isEmailVerified` - Перевірка статусу верифікації email

#### AuthWrapper (`lib/screens/auth_wrapper.dart`)

Автоматично керує навігацією на основі стану автентифікації:

- **Не авторизований** → LoginScreen або RegisterScreen
- **Авторизований, але email не верифікований** → EmailVerificationScreen
- **Авторизований і email верифікований** → HomeScreen

#### RegisterScreen

- Валідація email та паролю
- Реєстрація через Firebase
- Автоматична відправка листа з верифікацією
- Показ/приховування паролю
- Індикатор завантаження

#### LoginScreen

- Валідація email та паролю
- Вхід через Firebase
- Перевірка верифікації email
- Кнопка "Forgot Password"
- Показ/приховування паролю
- Індикатор завантаження

#### ForgotPasswordScreen

- Відправка листа для скидання паролю
- Валідація email
- Підтвердження відправки листа
- Повернення до екрану входу

#### EmailVerificationScreen

- Інформація про необхідність верифікації
- Кнопка перевірки верифікації
- Повторна відправка листа верифікації
- Кнопка виходу

### Безпека

- ✅ Паролі зберігаються в Firebase (хешовані)
- ✅ Валідація email на клієнті
- ✅ Мінімальна довжина паролю - 6 символів
- ✅ Обробка всіх помилок Firebase
- ✅ Перевірка верифікації email перед доступом

### Обробка помилок

AuthService обробляє наступні помилки Firebase:

- `weak-password` - Слабкий пароль
- `email-already-in-use` - Email вже використовується
- `invalid-email` - Невалідний email
- `user-not-found` - Користувача не знайдено
- `wrong-password` - Невірний пароль
- `too-many-requests` - Забагато спроб
- `invalid-credential` - Невірні credentials

### Тестування

#### Реєстрація нового користувача:
1. Відкрийте додаток
2. Введіть email та пароль (мінімум 6 символів)
3. Погодьтесь з умовами
4. Натисніть "Sign up"
5. Перевірте email для верифікації

#### Вхід:
1. Натисніть "Already have an account? Sign in"
2. Введіть email та пароль
3. Натисніть "Sign in"
4. Якщо email не верифікований, з'явиться екран верифікації

#### Скидання паролю:
1. На екрані входу натисніть "Forgot Password?"
2. Введіть email
3. Натисніть "Send Reset Link"
4. Перевірте email

### Troubleshooting

**Проблема**: "Email/password sign-in is not enabled"
**Рішення**: Увімкніть Email/Password в Firebase Console → Authentication → Sign-in method

**Проблема**: "Invalid email"
**Рішення**: Переконайтесь, що email має правильний формат

**Проблема**: Не приходить лист з верифікацією
**Рішення**: 
- Перевірте папку Spam
- Використайте кнопку "Resend Verification Email"
- Перевірте налаштування в Firebase Console

### Додаткові налаштування (опціонально)

#### Шаблони email:
Firebase Console → Authentication → Templates
Тут можна налаштувати:
- Email verification
- Password reset
- Email address change

#### Налаштування безпеки:
Firebase Console → Authentication → Settings
- Блокування користувачів після багатьох невдалих спроб
- Налаштування політики паролів
- Whitelist/Blacklist доменів email
