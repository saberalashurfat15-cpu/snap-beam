import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

/// Splash screen shown when the app launches
/// Displays the SnapBeam logo and tagline with animations
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showTagline = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Show tagline after delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showTagline = true);
      }
    });

    // Navigate to next screen after splash duration
    _startNavigationTimer();
  }

  void _startNavigationTimer() {
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    // Check if user has seen widget setup
    // In a real app, this would check SharedPreferences
    Navigator.pushReplacementNamed(context, '/widget-setup');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1), // Indigo
              Color(0xFF8B5CF6), // Purple
              Color(0xFFEC4899), // Pink
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            ..._buildBackgroundCircles(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon
                  _buildAppIcon(),

                  const SizedBox(height: 32),

                  // App Name
                  _buildAppName(),

                  const SizedBox(height: 16),

                  // Tagline
                  _buildTagline(),

                  const SizedBox(height: 32),

                  // Heart icon
                  _buildHeartIcon(),
                ],
              ),
            ),

            // Loading indicator at bottom
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: _buildLoadingIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundCircles() {
    return [
      Positioned(
        top: -100,
        right: -100,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
              duration: 2000.ms,
            )
            .fadeIn(duration: 1000.ms),
      ),
      Positioned(
        bottom: -150,
        left: -150,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.1, 1.1),
              duration: 2500.ms,
            ),
      ),
      Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: MediaQuery.of(context).size.width * 0.1,
        child: Container(
          width: 500,
          height: 500,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
        ).animate().fadeIn(duration: 1500.ms),
      ),
    ];
  }

  Widget _buildAppIcon() {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildAppName() {
    return const Text(
      'SnapBeam',
      style: TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -1,
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.3, end: 0, duration: 400.ms);
  }

  Widget _buildTagline() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 700),
      opacity: _showTagline ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 700),
        offset: _showTagline ? Offset.zero : const Offset(0, 0.3),
        child: Column(
          children: [
            Text(
              'Send moments. Instantly live on\nyour loved one\'s home screen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartIcon() {
    if (!_showTagline) return const SizedBox.shrink();

    return const Icon(
      Icons.favorite,
      size: 32,
      color: Colors.white,
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
          duration: 800.ms,
        );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ).animate(onPlay: (controller) => controller.repeat()).moveY(
              delay: Duration(milliseconds: index * 150),
              duration: 400.ms,
              begin: 0,
              end: -10,
            );
      }),
    );
  }
}
