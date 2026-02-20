import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io' show Platform;

import '../l10n/app_localizations.dart';

/// Widget setup screen that guides users through adding the widget
/// to their home screen
class WidgetSetupScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const WidgetSetupScreen({super.key, this.onComplete});

  @override
  State<WidgetSetupScreen> createState() => _WidgetSetupScreenState();
}

class _WidgetSetupScreenState extends State<WidgetSetupScreen> {
  int _currentStep = 0;
  late bool _isIOS;

  @override
  void initState() {
    super.initState();
    // Detect platform
    try {
      _isIOS = Platform.isIOS;
    } catch (_) {
      _isIOS = true; // Default to iOS for web
    }
  }

  List<SetupStep> get _steps => [
        SetupStep(
          title: 'Add Widget to Home Screen',
          description:
              'See photos from your loved ones instantly without opening the app.',
          icon: Icons.widgets_rounded,
          gradient: const [Color(0xFF6366F1), Color(0xFFEC4899)],
        ),
        SetupStep(
          title: _isIOS ? 'iOS Setup' : 'Android Setup',
          description: _isIOS
              ? 'Long press your home screen, tap the + button, search for SnapBeam, and add the widget.'
              : 'Long press your home screen, tap Widgets, find SnapBeam, and drag it to your home screen.',
          icon: Icons.smartphone_rounded,
          gradient: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
        ),
        SetupStep(
          title: 'You\'re All Set!',
          description:
              'Photos will appear on your widget automatically when shared.',
          icon: Icons.auto_awesome_rounded,
          gradient: const [Color(0xFF10B981), Color(0xFF14B8A6)],
        ),
      ];

  void _handleNext() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _completeSetup();
    }
  }

  void _handleSkip() {
    _completeSetup();
  }

  void _completeSetup() {
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final step = _steps[_currentStep];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildStepIcon(step),
                    const SizedBox(height: 32),
                    _buildStepTitle(step),
                    const SizedBox(height: 16),
                    _buildStepDescription(step),
                    const SizedBox(height: 32),
                    if (_currentStep == 1) _buildPlatformInstructions(),
                    if (_currentStep == 0) _buildWidgetPreview(),
                    if (_currentStep == 2) _buildSuccessAnimation(),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_steps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive
                  ? null
                  : isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepIcon(SetupStep step) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: step.gradient,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: step.gradient.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        step.icon,
        size: 48,
        color: Colors.white,
      ),
    )
        .animate(key: ValueKey('icon-$_currentStep'))
        .scale(
          duration: 400.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 300.ms);
  }

  Widget _buildStepTitle(SetupStep step) {
    return Text(
      step.title,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    )
        .animate(key: ValueKey('title-$_currentStep'))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildStepDescription(SetupStep step) {
    return Text(
      step.description,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    )
        .animate(key: ValueKey('desc-$_currentStep'))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildPlatformInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _isIOS ? Colors.black : const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isIOS ? Icons.apple : Icons.android,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isIOS ? 'iPhone/iPad' : 'Android Device',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    'Detected automatically',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._buildInstructionSteps(),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  List<Widget> _buildInstructionSteps() {
    final steps = _isIOS
        ? [
            'Long press on your home screen',
            'Tap the + button in the top left',
            'Search for SnapBeam',
            'Tap Add Widget',
          ]
        : [
            'Long press on your home screen',
            'Tap Widgets',
            'Find SnapBeam in the list',
            'Drag the widget to your home screen',
          ];

    final color = _isIOS
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF10B981);

    return steps.asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${entry.key + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildWidgetPreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 32),
              const SizedBox(height: 4),
              Text(
                'Widget',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(width: 16),
        Container(
          width: 144,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 40),
              const SizedBox(height: 4),
              Text(
                'SnapBeam',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, size: 64, color: Colors.white),
    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut).fadeIn(duration: 300.ms);
  }

  Widget _buildBottomButtons(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _handleNext,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(
                _currentStep < _steps.length - 1
                    ? Icons.arrow_forward_rounded
                    : Icons.auto_awesome_rounded,
              ),
              label: Text(
                _currentStep < _steps.length - 1 ? 'Next Step' : 'Get Started',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (_currentStep < _steps.length - 1) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _handleSkip,
              child: Text(
                'Skip for now',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Data class for setup steps
class SetupStep {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  const SetupStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
