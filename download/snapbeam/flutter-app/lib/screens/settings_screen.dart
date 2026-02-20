import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/connection_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final connectionProvider = context.read<ConnectionProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Connection Section
          _buildSectionHeader(context, 'Connection'),
          
          if (connectionProvider.connectionId != null)
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.link_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text('Code: ${connectionProvider.connectionId}'),
              subtitle: Text('Active connection'),
              trailing: IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () {
                  connectionProvider.shareCode();
                },
              ),
            ),
          
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            title: Text(l10n.regenerateCode),
            subtitle: Text('Create a new connection code'),
            onTap: () => _showRegenerateDialog(context),
          ),
          
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.link_off_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            title: Text(l10n.disconnect),
            subtitle: Text('End current connection'),
            onTap: () => _showDisconnectDialog(context),
          ),

          const Divider(height: 32),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),

          // Theme Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.palette_rounded,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.theme,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text(l10n.lightTheme),
                            icon: const Icon(Icons.light_mode_rounded),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text(l10n.darkTheme),
                            icon: const Icon(Icons.dark_mode_rounded),
                          ),
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text(l10n.systemTheme),
                            icon: const Icon(Icons.brightness_auto_rounded),
                          ),
                        ],
                        selected: {themeProvider.themeMode},
                        onSelectionChanged: (modes) {
                          themeProvider.setThemeMode(modes.first);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 32),

          // Widget Section
          _buildSectionHeader(context, l10n.widgetSetup),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.widgets_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add Widget',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.widgetInstructions,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Android: Long press home screen → Widgets → SnapBeam',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'iOS: Long press home screen → + → SnapBeam',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Divider(height: 32),

          // About Section
          _buildSectionHeader(context, l10n.aboutSnapbeam),
          
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(l10n.version),
            subtitle: const Text('1.0.0'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  void _showRegenerateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate Code'),
        content: const Text(
          'This will create a new connection code. Your current connection will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<ConnectionProvider>().createConnection();
            },
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.disconnect),
        content: const Text(
          'Are you sure you want to disconnect? You will need a new code to reconnect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<ConnectionProvider>().disconnect();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.disconnect),
          ),
        ],
      ),
    );
  }
}
