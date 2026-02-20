import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../providers/connection_provider.dart';

/// Widget to display connection code with share functionality
class ConnectionCodeDisplay extends StatelessWidget {
  final String code;

  const ConnectionCodeDisplay({
    super.key,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Label
        Text(
          l10n.yourCode,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        
        const SizedBox(height: 12),
        
        // Code Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Code characters
              ...code.split('').map((char) => Container(
                    width: 36,
                    height: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        char,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                  )),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

        const SizedBox(height: 16),

        // Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Copy Button
            TextButton.icon(
              onPressed: () => _copyCode(context),
              icon: const Icon(Icons.copy_rounded),
              label: Text('Copy'),
            ),
            
            const SizedBox(width: 16),
            
            // Share Button
            FilledButton.icon(
              onPressed: () => _shareCode(context),
              icon: const Icon(Icons.share_rounded),
              label: Text(l10n.shareCode),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareCode(BuildContext context) {
    Share.share(
      'Join my SnapBeam connection! Use code: $code\n\nDownload SnapBeam: https://snapbeam.app',
      subject: 'SnapBeam Connection Code',
    );
  }
}
