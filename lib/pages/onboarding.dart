import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:fooddelivery_app/service/widget_support.dart';
import 'signup.dart'; // Make sure you import the Signup page

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _subtitleController;
  late AnimationController _buttonController;
  late AnimationController _glowController;

  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _titleAnimation = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutBack,
    );

    _subtitleAnimation = CurvedAnimation(
      parent: _subtitleController,
      curve: Curves.easeOutBack,
    );

    _buttonAnimation = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutBack,
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _subtitleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _buttonController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Lottie.asset("images/deliver.json")),

            // Animated Title Container
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return ScaleTransition(
                  scale: _titleAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.deepOrange.withOpacity(_glowAnimation.value),
                          blurRadius: 28,
                          spreadRadius: 3,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.amberAccent
                              .withOpacity(_glowAnimation.value * 0.6),
                          blurRadius: 18,
                          spreadRadius: 1,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Fastest Food Delivery',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                                letterSpacing: 1.4,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color:
                                        Colors.orangeAccent.withOpacity(0.4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 4,
                              width: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF5F6D),
                                    Color(0xFFFFC371),
                                    Color(0xFFFFD194),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Subtitle
            ScaleTransition(
              scale: _subtitleAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text.rich(
                  TextSpan(
                    text: 'Good Food is\nJust a ',
                    style: AppWidget.containerStyle().copyWith(
                      fontSize: 24,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(
                        text: 'Click ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const TextSpan(text: 'Away'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Order Now Button
            ScaleTransition(
              scale: _buttonAnimation,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, _createRoute());
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFff5f6d),
                        Color(0xFFffc371),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.4),
                        offset: const Offset(0, 8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Order Now",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 👇 Slide transition method to Signup page
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const SignUp(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) { 
        const begin = Offset(1.0, 0.0); // Slide from right
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
 