import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/connection_provider.dart';
import '../widgets/connection_code_display.dart';
import '../widgets/join_connection_dialog.dart';
import 'camera_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  Future<void> _createConnection() async {
    setState(() => _isLoading = true);
    
    try {
      await context.read<ConnectionProvider>().createConnection();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.connectionCreated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showJoinDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const JoinConnectionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final connectionProvider = context.watch<ConnectionProvider>();
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo and Title
              _buildHeader(context, l10n),
              
              const Spacer(flex: 2),
              
              // Connection State
              if (connectionProvider.isConnected)
                _buildConnectedState(context, l10n, connectionProvider)
              else
                _buildDisconnectedState(context, l10n),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // App Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 60,
            color: Colors.white,
          ),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 400.ms),
        
        const SizedBox(height: 24),
        
        // Title
        Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 12),
        
        // Tagline
        Text(
          l10n.tagline,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildConnectedState(
    BuildContext context,
    AppLocalizations l10n,
    ConnectionProvider connectionProvider,
  ) {
    return Column(
      children: [
        // Connection Code Display
        ConnectionCodeDisplay(
          code: connectionProvider.connectionId!,
        ),
        
        const SizedBox(height: 24),
        
        // Take Photo Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CameraScreen()),
              );
            },
            icon: const Icon(Icons.camera_alt_rounded),
            label: Text(l10n.takePhoto),
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildDisconnectedState(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // Create Connection Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _createConnection,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add_link_rounded),
            label: Text(l10n.createConnection),
          ),
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 16),
        
        // Join Connection Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _showJoinDialog,
            icon: const Icon(Icons.link_rounded),
            label: Text(l10n.joinConnection),
          ),
        )
            .animate()
            .fadeIn(delay: 800.ms, duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }
}
