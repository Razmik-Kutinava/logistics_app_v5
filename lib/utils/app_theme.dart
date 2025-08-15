import 'package:flutter/material.dart';

class AppTheme {
  // Цветовая схема CIO Logistics - Вариант 1 (контрастный)
  // Основные цвета
  static const Color primaryDarkBlue = Color(0xFF003366); // Темно-синий
  static const Color accentOrange = Color(0xFFFF6600); // Оранжевый
  static const Color backgroundWhite = Color(0xFFFFFFFF); // Белый
  static const Color statusGreen = Color(0xFF00AA00); // Зеленый для статусов
  static const Color completedGray = Color(0xFFAAAAAA); // Серый для завершенных

  // Дополнительные цвета
  static const Color darkCardColor =
      Color(0xFF004080); // Темно-синий для карточек
  static const Color textDark = Color(0xFF003366); // Темный текст
  static const Color textLight = Color(0xFFFFFFFF); // Светлый текст
  static const Color errorRed = Color(0xFFEE0000); // Красный для ошибок
  static const Color warningAmber =
      Color(0xFFFF8C00); // Янтарный для предупреждений

  // Адаптивные размеры для водителей 35+ (крупнее для лучшей видимости)
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Увеличиваем базовые размеры шрифтов на 30% для лучшей читаемости
    final adjustedBase = baseSize * 1.3;
    if (screenWidth < 360) return adjustedBase * 1.0;
    if (screenWidth < 400) return adjustedBase * 1.1;
    if (screenWidth > 600) return adjustedBase * 1.2;
    return adjustedBase;
  }

  static double getResponsivePadding(BuildContext context, double basePadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Увеличиваем отступы для более комфортного касания
    final adjustedBase = basePadding * 1.4;
    if (screenWidth < 360) return adjustedBase * 0.9;
    if (screenWidth > 600) return adjustedBase * 1.2;
    return adjustedBase;
  }

  // Размеры для кнопок (крупнее для лучшего касания)
  static double getButtonHeight(BuildContext context) {
    return 60.0; // Минимум 60px для удобного касания водителей
  }

  // Размеры иконок (крупнее для лучшей видимости)
  static double getIconSize(BuildContext context, double baseSize) {
    return baseSize * 1.5; // Увеличиваем иконки на 50%
  }

  // Светлая тема CIO Logistics (основная для водителей)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        background: backgroundWhite,
        surface: backgroundWhite,
        primary: primaryDarkBlue,
        secondary: accentOrange,
        error: errorRed,
        onBackground: textDark,
        onSurface: textDark,
        onPrimary: textLight,
        outline: primaryDarkBlue.withOpacity(0.3),
      ),
      scaffoldBackgroundColor: backgroundWhite,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryDarkBlue,
        foregroundColor: textLight,
        elevation: 4,
        centerTitle: true,
        shadowColor: Colors.black26,
        titleTextStyle: const TextStyle(
          fontSize: 24, // Крупный размер для водителей
          fontWeight: FontWeight.bold,
          color: textLight,
          fontFamily: 'Roboto',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentOrange,
          foregroundColor: textLight,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontSize: 20, // Крупный текст на кнопках
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
          minimumSize: const Size(double.infinity, 60), // Высокие кнопки
          elevation: 6,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDarkBlue,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDarkBlue,
          side: const BorderSide(color: primaryDarkBlue, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryDarkBlue, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: primaryDarkBlue.withOpacity(0.5), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentOrange, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        labelStyle: TextStyle(
          fontSize: 18,
          color: textDark.withOpacity(0.7),
          fontFamily: 'Roboto',
        ),
        hintStyle: TextStyle(
          fontSize: 18,
          color: textDark.withOpacity(0.5),
          fontFamily: 'Roboto',
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        color: backgroundWhite,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundWhite,
        selectedItemColor: accentOrange,
        unselectedItemColor: textDark.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontFamily: 'Roboto',
        ),
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedIconTheme: const IconThemeData(size: 26),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accentOrange,
        unselectedLabelColor: textDark.withOpacity(0.7),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontFamily: 'Roboto',
        ),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: accentOrange.withOpacity(0.2),
        ),
        indicatorColor: accentOrange,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Roboto',
        ),
        headlineMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Roboto',
        ),
        headlineSmall: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Roboto',
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Roboto',
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textDark,
          fontFamily: 'Roboto',
        ),
        titleSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textDark,
          fontFamily: 'Roboto',
        ),
        bodyLarge: TextStyle(
          fontSize: 20,
          color: textDark,
          fontFamily: 'Roboto',
        ),
        bodyMedium: TextStyle(
          fontSize: 18,
          color: textDark,
          fontFamily: 'Roboto',
        ),
        bodySmall: TextStyle(
          fontSize: 16,
          color: textDark.withOpacity(0.8),
          fontFamily: 'Roboto',
        ),
        labelLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Roboto',
        ),
        labelMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDark,
          fontFamily: 'Roboto',
        ),
        labelSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark.withOpacity(0.8),
          fontFamily: 'Roboto',
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentOrange,
        foregroundColor: textLight,
        elevation: 8,
        focusElevation: 12,
        hoverElevation: 10,
        splashColor: accentOrange.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Темная тема CIO Logistics (для ночного вождения)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        background: primaryDarkBlue,
        surface: darkCardColor,
        primary: accentOrange,
        secondary: statusGreen,
        error: errorRed,
        onBackground: textLight,
        onSurface: textLight,
        onPrimary: primaryDarkBlue,
        outline: textLight.withOpacity(0.3),
      ),
      scaffoldBackgroundColor: primaryDarkBlue,
      appBarTheme: AppBarTheme(
        backgroundColor: darkCardColor,
        foregroundColor: textLight,
        elevation: 4,
        centerTitle: true,
        shadowColor: Colors.black54,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textLight,
          fontFamily: 'Roboto',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentOrange,
          foregroundColor: primaryDarkBlue,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
          minimumSize: const Size(double.infinity, 60),
          elevation: 8,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentOrange,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: textLight.withOpacity(0.5), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: textLight.withOpacity(0.3), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentOrange, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        labelStyle: TextStyle(
          fontSize: 18,
          color: textLight.withOpacity(0.7),
          fontFamily: 'Roboto',
        ),
        hintStyle: TextStyle(
          fontSize: 18,
          color: textLight.withOpacity(0.5),
          fontFamily: 'Roboto',
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        color: darkCardColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkCardColor,
        selectedItemColor: accentOrange,
        unselectedItemColor: textLight.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontFamily: 'Roboto',
        ),
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedIconTheme: const IconThemeData(size: 26),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: textLight,
          fontFamily: 'Roboto',
        ),
        headlineMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: textLight,
          fontFamily: 'Roboto',
        ),
        headlineSmall: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: textLight,
          fontFamily: 'Roboto',
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textLight,
          fontFamily: 'Roboto',
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textLight,
          fontFamily: 'Roboto',
        ),
        titleSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textLight,
          fontFamily: 'Roboto',
        ),
        bodyLarge: TextStyle(
          fontSize: 20,
          color: textLight,
          fontFamily: 'Roboto',
        ),
        bodyMedium: TextStyle(
          fontSize: 18,
          color: textLight,
          fontFamily: 'Roboto',
        ),
        bodySmall: TextStyle(
          fontSize: 16,
          color: textLight.withOpacity(0.8),
          fontFamily: 'Roboto',
        ),
        labelLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textLight,
          fontFamily: 'Roboto',
        ),
        labelMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textLight,
          fontFamily: 'Roboto',
        ),
        labelSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textLight.withOpacity(0.8),
          fontFamily: 'Roboto',
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentOrange,
        foregroundColor: primaryDarkBlue,
        elevation: 10,
        focusElevation: 14,
        hoverElevation: 12,
        splashColor: accentOrange.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Цвета статусов заказов
  static Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'ожидает':
        return accentOrange;
      case 'confirmed':
      case 'подтвержден':
        return accentOrange;
      case 'intransit':
      case 'в пути':
        return primaryDarkBlue;
      case 'delivered':
      case 'доставлен':
        return statusGreen;
      case 'cancelled':
      case 'отменен':
        return completedGray;
      default:
        return textDark;
    }
  }

  // Размеры для кнопок по категориям
  static EdgeInsets get primaryButtonPadding =>
      const EdgeInsets.symmetric(horizontal: 32, vertical: 20);

  static EdgeInsets get secondaryButtonPadding =>
      const EdgeInsets.symmetric(horizontal: 24, vertical: 16);

  static EdgeInsets get cardPadding => const EdgeInsets.all(20);

  static EdgeInsets get screenPadding =>
      const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
}
