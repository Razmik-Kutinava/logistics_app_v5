import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:logistics_app/providers/auth_provider.dart';
import 'package:logistics_app/providers/order_provider.dart';

import 'package:logistics_app/screens/home_screen.dart';
import 'package:logistics_app/screens/login_screen.dart';
import 'package:logistics_app/screens/orders_screen.dart';
import 'package:logistics_app/screens/profile_screen.dart';
import 'package:logistics_app/screens/splash_screen.dart';
import 'package:logistics_app/screens/qr_scanner_screen.dart';
import 'package:logistics_app/utils/app_theme.dart';

void main() {
  runApp(const LogisticsApp());
}

class LogisticsApp extends StatelessWidget {
  const LogisticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp.router(
        title: 'Logistics App - Для водителей',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
    GoRoute(
        path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(
        path: '/qr-scanner',
        builder: (context, state) => const QRScannerScreen()),
  ],
);
