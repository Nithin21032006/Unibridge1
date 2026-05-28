import 'package:flutter/material.dart';
import 'utils/routes.dart';

void main() {
  runApp(const UniBridgeApp());
}

class UniBridgeApp extends StatelessWidget {
  const UniBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
    );
  }
}