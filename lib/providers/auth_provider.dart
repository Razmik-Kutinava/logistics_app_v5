import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logistics_app/models/user.dart';
import 'package:logistics_app/models/driver.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  Driver? _driver;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  Driver? get driver => _driver;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Тестовые данные для входа (водители CIO Logistics)
  static const Map<String, Map<String, String>> _testCredentials = {
    '+37491123456': {
      'password': '123456',
      'name': 'Арам Григорян',
      'email': 'aram.grigoryan@cio-logistics.am',
      'role': 'driver',
      'id': 'driver_001',
    },
    '+37491234567': {
      'password': '654321',
      'name': 'Давид Саркисян',
      'email': 'david.sarkisyan@cio-logistics.am',
      'role': 'driver',
      'id': 'driver_002',
    },
    '+37491345678': {
      'password': '111111',
      'name': 'Вартан Хачатрян',
      'email': 'vartan.khachatryan@cio-logistics.am',
      'role': 'driver',
      'id': 'driver_003',
    },
    '+37495123456': {
      'password': '999999',
      'name': 'Админ Системы',
      'email': 'admin@cio-logistics.am',
      'role': 'admin',
      'id': 'admin_001',
    },
  };

  // Нормализация армянского номера телефона
  String _normalizePhone(String phone) {
    // Убираем все, кроме цифр и плюса
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Если номер начинается с 0 (местный армянский формат)
    if (cleaned.startsWith('0') && cleaned.length == 9) {
      cleaned = '+374${cleaned.substring(1)}';
    }

    // Если номер без кода страны (8 цифр)
    if (cleaned.length == 8 && !cleaned.startsWith('+')) {
      cleaned = '+374$cleaned';
    }

    // Если начинается с 374 без +
    if (cleaned.startsWith('374') && !cleaned.startsWith('+374')) {
      cleaned = '+$cleaned';
    }

    print('Нормализованный телефон: $cleaned');
    return cleaned;
  }

  // Поиск по нормализованному номеру
  String? _findPhoneInCredentials(String inputPhone) {
    String normalizedInput = _normalizePhone(inputPhone);

    for (String credPhone in _testCredentials.keys) {
      String normalizedCred = _normalizePhone(credPhone);
      if (normalizedCred == normalizedInput) {
        return credPhone;
      }
    }
    return null;
  }

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Имитация API запроса
      await Future.delayed(const Duration(seconds: 1));

      print('AuthProvider: Проверяем телефон: $phone');
      print('AuthProvider: Доступные телефоны: ${_testCredentials.keys}');

      // Ищем телефон по нормализованному номеру
      String? foundPhone = _findPhoneInCredentials(phone);

      // Проверяем тестовые данные
      if (foundPhone != null) {
        final userData = _testCredentials[foundPhone]!;
        print('AuthProvider: Найден пользователь, проверяем пароль');
        print('AuthProvider: Ожидаемый пароль: ${userData['password']}');
        print('AuthProvider: Введенный пароль: $password');

        if (userData['password'] == password) {
          _user = User(
            id: userData['id']!,
            name: userData['name']!,
            email: userData['email']!,
            role: userData['role']!,
            phone: foundPhone,
          );

          // Если это водитель, создаем объект Driver
          if (userData['role'] == 'driver') {
            _driver = Driver(
              id: userData['id']!,
              fullName: userData['name']!,
              phone: foundPhone,
              email: userData['email']!,
              passportNumber: 'AN${userData['id']!.substring(7)}',
              passportIssuedBy: 'МВД РА',
              passportIssuedDate: DateTime(2015, 3, 15),
              licenseNumber: 'VOD${userData['id']!.substring(7)}',
              licenseCategory: 'B, C',
              licenseIssuedDate: DateTime(2014, 8, 20),
              licenseExpiryDate: DateTime(2029, 8, 20),
              completedRides: 1247,
              cancelledRides: 23,
              rating: 4.8,
              workStartDate: DateTime(2021, 5, 10),
              isActive: true,
              receiveNotifications: true,
              isOnline: true,
              lastActiveAt: DateTime.now(),
            );
          }

          // Сохраняем данные пользователя
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_phone', foundPhone);
          await prefs.setString('user_data', _user!.toJson().toString());
          if (_driver != null) {
            await prefs.setString('driver_data', _driver!.toJson().toString());
          }

          _isLoading = false;
          notifyListeners();
          print('AuthProvider: Вход успешен!');
          return true;
        } else {
          print('AuthProvider: Неверный пароль');
        }
      } else {
        print('AuthProvider: Телефон не найден в базе');
      }

      _error = 'Неверный номер телефона или пароль';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Ошибка подключения';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _driver = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_phone');
    await prefs.remove('user_data');
    await prefs.remove('driver_data');
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userPhone = prefs.getString('user_phone');
    final userData = prefs.getString('user_data');
    final driverData = prefs.getString('driver_data');

    if (userPhone != null &&
        userData != null &&
        _testCredentials.containsKey(userPhone)) {
      // В реальном приложении здесь была бы проверка токена
      final testData = _testCredentials[userPhone]!;
      _user = User(
        id: testData['id']!,
        name: testData['name']!,
        email: testData['email']!,
        role: testData['role']!,
        phone: userPhone,
      );

      // Восстанавливаем данные водителя если это водитель
      if (testData['role'] == 'driver' && driverData != null) {
        _driver = Driver(
          id: testData['id']!,
          fullName: testData['name']!,
          phone: userPhone,
          email: testData['email']!,
          passportNumber: 'AN${testData['id']!.substring(7)}',
          passportIssuedBy: 'МВД РА',
          passportIssuedDate: DateTime(2015, 3, 15),
          licenseNumber: 'VOD${testData['id']!.substring(7)}',
          licenseCategory: 'B, C',
          licenseIssuedDate: DateTime(2014, 8, 20),
          licenseExpiryDate: DateTime(2029, 8, 20),
          completedRides: 1247,
          cancelledRides: 23,
          rating: 4.8,
          workStartDate: DateTime(2021, 5, 10),
          isActive: true,
          receiveNotifications: true,
          isOnline: true,
          lastActiveAt: DateTime.now(),
        );
      }

      notifyListeners();
    }
  }

  // Обновить статус водителя (онлайн/оффлайн)
  Future<void> updateDriverStatus(bool isOnline) async {
    if (_driver != null) {
      _driver = _driver!.copyWith(
        isOnline: isOnline,
        lastActiveAt: DateTime.now(),
      );

      // Сохраняем обновленные данные
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('driver_data', _driver!.toJson().toString());

      notifyListeners();
    }
  }

  // Обновить настройки уведомлений
  Future<void> updateNotificationSettings(bool receiveNotifications) async {
    if (_driver != null) {
      _driver = _driver!.copyWith(receiveNotifications: receiveNotifications);

      // Сохраняем обновленные данные
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('driver_data', _driver!.toJson().toString());

      notifyListeners();
    }
  }

  // Получить список доступных тестовых телефонов (для отладки)
  static List<String> getTestPhones() {
    return _testCredentials.keys.toList();
  }

  // Получить тестовый пароль для телефона (для отладки)
  static String? getTestPassword(String phone) {
    return _testCredentials[phone]?['password'];
  }

  // Проверить, является ли пользователь водителем
  bool get isDriver => _user?.role == 'driver';

  // Проверить, является ли пользователь администратором
  bool get isAdmin => _user?.role == 'admin';
}
