import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/app_localizations.dart';
import '../providers/connection_provider.dart';
import '../services/backend_service.dart';
import '../services/usage_service.dart';
import 'premium_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final _captionController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _usageService = UsageService();
  File? _selectedImage;
  bool _isSending = false;
  int _remainingSends = 2;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsageData();
  }

  Future<void> _loadUsageData() async {
    final remaining = await _usageService.getRemainingSends();
    setState(() {
      _remainingSends = remaining;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        // Compress image
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          image.path,
          minHeight: 800,
          minWidth: 800,
          quality: 80,
          format: CompressFormat.jpeg,
        );

        if (compressedBytes != null) {
          setState(() {
            _selectedImage = File(image.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _sendPhoto() async {
    if (_selectedImage == null) return;

    // Check daily limit
    final canSend = await _usageService.canSend();
    if (!canSend) {
      _showLimitReachedDialog();
      return;
    }

    setState(() => _isSending = true);

    try {
      final connectionProvider = context.read<ConnectionProvider>();
      final connectionId = connectionProvider.connectionId;

      if (connectionId == null) {
        throw Exception('No active connection');
      }

      // Read and encode image
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Send to backend
      await BackendService().updatePhoto(
        connectionId: connectionId,
        photoBase64: base64Image,
        caption: _captionController.text.trim(),
      );

      // Record the send
      await _usageService.recordSend();

      // Update remaining count
      final newRemaining = await _usageService.getRemainingSends();
      setState(() => _remainingSends = newRemaining);

      // Vibrate on success
      try {
        await Vibration.vibrate(duration: 100);
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.photoSent),
            backgroundColor: Colors.green,
          ),
        );

        _captionController.clear();
        setState(() => _selectedImage = null);
        Navigator.pop(context);
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
      setState(() => _isSending = false);
    }
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.block_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Daily Limit Reached'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You\'ve used your 2 free photo sends for today.\n\n'
              'Upgrade to Premium for unlimited sends!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: FutureBuilder<String>(
                future: _usageService.getTimeUntilReset(),
                builder: (context, snapshot) {
                  return Text(
                    'Resets in: ${snapshot.data ?? "..."}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
            icon: const Icon(Icons.diamond_rounded),
            label: const Text('Go Premium'),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text(AppLocalizations.of(context)!.camera),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(AppLocalizations.of(context)!.gallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.takePhoto),
        centerTitle: true,
        actions: [
          // Premium button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.diamond_rounded, color: Colors.white, size: 18),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Daily limit indicator
            _buildLimitIndicator(context),

            const SizedBox(height: 24),

            // Image Preview
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 350,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_rounded,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tap to add a photo',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

            const SizedBox(height: 24),

            // Caption Input
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                hintText: l10n.addCaption,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              maxLines: 2,
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Send Button
            FilledButton.icon(
              onPressed: _selectedImage != null && !_isSending && _remainingSends > 0
                  ? _sendPhoto
                  : null,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_isSending ? 'Sending...' : l10n.sendPhoto),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),

            // Upgrade prompt if limit reached
            if (_remainingSends == 0) ...[
              const SizedBox(height: 16),
              _buildUpgradePrompt(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLimitIndicator(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()));
    }

    final remaining = _remainingSends == -1 ? '∞' : _remainingSends.toString();
    final isUnlimited = _remainingSends == -1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isUnlimited
            ? const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)])
            : null,
        color: isUnlimited ? null : Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUnlimited ? Icons.diamond_rounded : Icons.photo_camera_rounded,
            size: 20,
            color: isUnlimited ? Colors.white : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            isUnlimited
                ? 'Premium: Unlimited Sends'
                : 'Free Plan: $remaining sends remaining today',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isUnlimited ? Colors.white : Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildUpgradePrompt(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PremiumScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.diamond_rounded, color: Colors.white),
            const SizedBox(width: 12),
            const Text(
              'Upgrade to Premium for Unlimited Sends',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }
}
