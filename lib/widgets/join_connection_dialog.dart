import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/connection_provider.dart';

/// Dialog for joining an existing connection with a code
class JoinConnectionDialog extends StatefulWidget {
  const JoinConnectionDialog({super.key});

  @override
  State<JoinConnectionDialog> createState() => _JoinConnectionDialogState();
}

class _JoinConnectionDialogState extends State<JoinConnectionDialog> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeController.text.trim().toUpperCase();
    
    if (code.length < 6) {
      setState(() => _error = 'Code must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await context.read<ConnectionProvider>().joinConnection(code);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.connectionJoined),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              l10n.joinConnection,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              l10n.enterCode,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Code Input
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
              decoration: InputDecoration(
                hintText: 'XXXXXXXX',
                counterText: '',
                errorText: _error,
              ),
              maxLength: 8,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              ],
              onChanged: (value) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 24),
            
            // Join Button
            FilledButton(
              onPressed: _isLoading ? null : _join,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.confirm),
            ),
            
            const SizedBox(height: 12),
            
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
