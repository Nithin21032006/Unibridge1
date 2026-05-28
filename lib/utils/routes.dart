import 'package:flutter/material.dart';
import '../pages/welcome_page.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/studenthome.dart' as student;
import '../pages/eventhome.dart' as event;
import '../pages/facultyhome.dart' as faculty;
import '../pages/resolvecomp.dart' as resolve;
import '../pages/task.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String studentHome = '/student-home';
  static const String facultyHome = '/faculty-home';
  static const String eventHome = '/event-home';
  static const String taskManager = '/task-manager';
  static const String resolutionCentre = '/resolution-centre';

  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomePage(),
    login: (context) => const LoginPage(),
    signup: (context) => const SignupPage(),
    studentHome: (context) => const student.HomePage(),
    facultyHome: (context) => const faculty.HomePage(),
    eventHome: (context) => const event.HomePage(),
    taskManager: (context) => const TaskManagerPage(),
    resolutionCentre: (context) => const resolve.ResolutionCentreScreen(),
  };
}
