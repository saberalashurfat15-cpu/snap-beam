import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Premium screen showing upcoming features and "Coming Soon" badge
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Premium badge
            _buildPremiumBadge(),

            const SizedBox(height: 24),

            // Coming Soon badge
            _buildComingSoonBadge(context),

            const SizedBox(height: 32),

            // Features list
            _buildFeaturesList(context),

            const SizedBox(height: 32),

            // Pricing teaser
            _buildPricingTeaser(context),

            const SizedBox(height: 32),

            // Notify me button
            _buildNotifyButton(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFBBF24), // Amber
            Color(0xFFF59E0B), // Orange
            Color(0xFFEF4444), // Red
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFBBF24).withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: const Icon(
        Icons.diamond_rounded,
        size: 60,
        color: Colors.white,
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).fadeIn();
  }

  Widget _buildComingSoonBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Coming Soon',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      {'icon': Icons.all_inclusive, 'title': 'Unlimited Photo Sends', 'desc': 'No daily limits'},
      {'icon': Icons.hd, 'title': 'HD Quality Photos', 'desc': 'Full resolution sharing'},
      {'icon': Icons.history, 'title': 'Photo History', 'desc': '30-day photo archive'},
      {'icon': Icons.palette, 'title': 'Custom Widget Themes', 'desc': 'Personalize your widgets'},
      {'icon': Icons.group_add, 'title': 'Multiple Connections', 'desc': 'Connect with more people'},
      {'icon': Icons.notifications_active, 'title': 'Priority Support', 'desc': 'Fast response times'},
    ];

    return Column(
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFBBF24).withOpacity(0.2),
                        const Color(0xFFF59E0B).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        feature['desc'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFFF59E0B),
                  size: 24,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 400 + (index * 100))).slideX(begin: 0.1, end: 0);
      }).toList(),
    );
  }

  Widget _buildPricingTeaser(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Expected Pricing',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPriceOption(context, 'Monthly', '\$2.99', false),
              _buildPriceOption(context, 'Yearly', '\$19.99', true),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Save 44% with yearly plan!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildPriceOption(BuildContext context, String period, String price, bool isPopular) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isPopular ? Theme.of(context).colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPopular ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        children: [
          Text(
            period,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isPopular ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPopular ? Colors.white : null,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifyButton(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: () {
              // Show notification signup dialog
              _showNotifyDialog(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.notifications_active_rounded),
            label: const Text(
              'Notify Me When Available',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        Text(
          'We\'ll let you know when Premium launches!',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  void _showNotifyDialog(BuildContext context) {
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
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.diamond_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Stay Tuned!'),
          ],
        ),
        content: const Text(
          'We\'re working hard to bring you Premium features. '
          'We\'ll notify you through the app when it\'s available!\n\n'
          'Thank you for your interest in SnapBeam Premium.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
