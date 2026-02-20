import 'package:shared_preferences/shared_preferences.dart';

/// Usage tracking service for managing daily photo send limits
/// Free users: 2 photos per day
/// Premium users: Unlimited (coming soon)
class UsageService {
  static const int _freeDailyLimit = 2;
  static const String _sendsKey = 'daily_sends';
  static const String _lastResetKey = 'last_reset_date';
  static const String _isPremiumKey = 'is_premium';

  /// Get the number of sends remaining today
  Future<int> getRemainingSends() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if premium
    final isPremium = prefs.getBool(_isPremiumKey) ?? false;
    if (isPremium) return -1; // -1 indicates unlimited

    // Check if we need to reset the counter (new day)
    await _checkAndResetIfNeeded(prefs);

    final sends = prefs.getInt(_sendsKey) ?? 0;
    return (_freeDailyLimit - sends).clamp(0, _freeDailyLimit);
  }

  /// Get the number of sends used today
  Future<int> getUsedSends() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkAndResetIfNeeded(prefs);
    return prefs.getInt(_sendsKey) ?? 0;
  }

  /// Record a photo send
  /// Returns true if successful, false if limit reached
  Future<bool> recordSend() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if premium
    final isPremium = prefs.getBool(_isPremiumKey) ?? false;
    if (isPremium) return true;

    await _checkAndResetIfNeeded(prefs);

    final currentSends = prefs.getInt(_sendsKey) ?? 0;
    
    if (currentSends >= _freeDailyLimit) {
      return false; // Limit reached
    }

    await prefs.setInt(_sendsKey, currentSends + 1);
    return true;
  }

  /// Check if user can send a photo
  Future<bool> canSend() async {
    final remaining = await getRemainingSends();
    return remaining > 0 || remaining == -1; // -1 = unlimited (premium)
  }

  /// Check if user is premium
  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isPremiumKey) ?? false;
  }

  /// Set premium status (for testing or after purchase)
  Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, value);
  }

  /// Get time until reset (in hours and minutes)
  Future<String> getTimeUntilReset() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final difference = tomorrow.difference(now);
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    return '${hours}h ${minutes}m';
  }

  /// Reset the daily counter if it's a new day
  Future<void> _checkAndResetIfNeeded(SharedPreferences prefs) async {
    final now = DateTime.now();
    final today = '${now.year}-${now.month}-${now.day}';
    final lastReset = prefs.getString(_lastResetKey);

    if (lastReset != today) {
      await prefs.setInt(_sendsKey, 0);
      await prefs.setString(_lastResetKey, today);
    }
  }

  /// Reset all usage data (for testing)
  Future<void> resetUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sendsKey);
    await prefs.remove(_lastResetKey);
    await prefs.remove(_isPremiumKey);
  }
}
