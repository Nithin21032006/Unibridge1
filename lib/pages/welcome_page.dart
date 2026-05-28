/// UNI BRIDGE OPENING ANIMATION
/// Woman and man walk from opposite sides
/// Bridge grows between them dynamically
/// Then logo appears

import 'dart:async';
import 'package:flutter/material.dart';

import '../utils/routes.dart';

void main() {
  runApp(const UniBridgeApp());
}

class UniBridgeApp extends StatelessWidget {
  const UniBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UniBridgeIntro(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  static const String routeName = AppRoutes.welcome;

  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UniBridgeIntro();
  }
}

class UniBridgeIntro extends StatefulWidget {
  const UniBridgeIntro({super.key});

  @override
  State<UniBridgeIntro> createState() => _UniBridgeIntroState();
}

class _UniBridgeIntroState extends State<UniBridgeIntro>
    with TickerProviderStateMixin {

  late AnimationController walkController;
  late AnimationController logoController;

  @override
  void initState() {
    super.initState();

    walkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    startAnimation();
  }

  Future<void> startAnimation() async {

    /// Start walking
    walkController.forward();

    await Future.delayed(const Duration(seconds: 5));

    /// Show logo
    logoController.forward();
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    walkController.dispose();
    logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),

      body: Stack(
        children: [

          /// LIGHT BACKGROUND CITY EFFECT
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: Image.network(
                "https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b",
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// BRIDGE
          AnimatedBuilder(
            animation: walkController,
            builder: (context, child) {

              /// Bridge grows based on animation
              double bridgeWidth = width * walkController.value;

              return Positioned(
                bottom: 180,
                left: width / 2 - bridgeWidth / 2,
                child: Container(
                  width: bridgeWidth,
                  height: 180,

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF001B7A),
                        Color(0xFF3B82F6),
                      ],
                    ),

                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(300),
                      topRight: Radius.circular(300),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                ),
              );
            },
          ),

          /// LEFT WOMAN
          AnimatedBuilder(
            animation: walkController,
            builder: (context, child) {

              double x = Tween<double>(
                begin: -80,
                end: width / 2 - 110,
              ).evaluate(walkController);

              return Positioned(
                left: x,
                bottom: 310,
                child: person(
                  isWoman: true,
                  animationValue: walkController.value,
                ),
              );
            },
          ),

          /// RIGHT MAN
          AnimatedBuilder(
            animation: walkController,
            builder: (context, child) {

              double x = Tween<double>(
                begin: width,
                end: width / 2 + 30,
              ).evaluate(walkController);

              return Positioned(
                left: x,
                bottom: 310,
                child: person(
                  isWoman: false,
                  animationValue: walkController.value,
                ),
              );
            },
          ),

          /// HANDSHAKE GLOW
          AnimatedBuilder(
            animation: walkController,
            builder: (context, child) {

              double opacity =
                  walkController.value > 0.85
                      ? (walkController.value - 0.85) * 7
                      : 0;

              return Center(
                child: Opacity(
                  opacity: opacity.clamp(0, 1),

                  child: Container(
                    margin: const EdgeInsets.only(bottom: 130),

                    width: 120,
                    height: 120,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.15),
                    ),

                    child: const Icon(
                      Icons.handshake,
                      color: Colors.blue,
                      size: 60,
                    ),
                  ),
                ),
              );
            },
          ),

          /// LOGO
          AnimatedBuilder(
            animation: logoController,
            builder: (context, child) {

              return Align(
                alignment: Alignment.bottomCenter,

                child: Opacity(
                  opacity: logoController.value,

                  child: Transform.translate(
                    offset: Offset(
                      0,
                      40 * (1 - logoController.value),
                    ),

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 70),

                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [
                              Color(0xFF001B7A),
                              Color(0xFF3B82F6),
                            ],
                          ).createShader(bounds);
                        },

                        child: const Text(
                          "UniBridge",
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget person({
    required bool isWoman,
    required double animationValue,
  }) {

    /// WALKING BOUNCE
    double bounce =
        ((animationValue * 12) % 1 < 0.5)
            ? 0
            : 6;

    /// LEG ROTATION
    double legAngle =
        ((animationValue * 2) % 1 - 0.5) * 0.9;

    return Transform.translate(
      offset: Offset(0, bounce),

      child: Column(
        children: [

          /// HEAD
          Container(
            width: 34,
            height: 34,

            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF111827),
            ),
          ),

          /// BODY
          Container(
            width: 52,
            height: 90,

            decoration: BoxDecoration(
              color: const Color(0xFF0F2E8A),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          /// LEGS
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              Transform.rotate(
                angle: legAngle,

                alignment: Alignment.topCenter,

                child: leg(),
              ),

              const SizedBox(width: 10),

              Transform.rotate(
                angle: -legAngle,

                alignment: Alignment.topCenter,

                child: leg(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget leg() {

    return Container(
      width: 9,
      height: 52,

      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
