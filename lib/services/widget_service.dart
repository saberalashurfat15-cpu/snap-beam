import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Widget service for managing home screen widgets
/// 
/// Uses SharedPreferences to store data that both the Flutter app
/// and the native Android widget can access.
/// 
/// Android widget reads from SharedPreferences with the key format:
/// "flutter.<key>" (added automatically by SharedPreferences package)
class WidgetService {
  // These keys are stored as "flutter.last_photo" etc in SharedPreferences
  // The Android widget reads with the "flutter." prefix
  static const String _keyPhoto = 'last_photo';
  static const String _keyCaption = 'last_caption';
  static const String _keyUpdatedAt = 'last_updated_at';
  static const String _keyConnectionId = 'connection_id';

  /// Initialize widget service
  static Future<void> initialize() async {
    debugPrint('WidgetService initialized');
  }

  /// Update widget with new photo
  static Future<void> updateWidget({
    required String connectionId,
    String? photoBase64,
    String? photoUrl,
    String? caption,
    DateTime? updatedAt,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save all data
      if (photoBase64 != null) {
        await prefs.setString(_keyPhoto, photoBase64);
      }
      
      if (caption != null) {
        await prefs.setString(_keyCaption, caption);
      }
      
      if (updatedAt != null) {
        await prefs.setString(_keyUpdatedAt, updatedAt.toIso8601String());
      }
      
      await prefs.setString(_keyConnectionId, connectionId);

      debugPrint('Widget data saved: photo=${photoBase64 != null}, caption=$caption');
    } catch (e) {
      debugPrint('Error saving widget data: $e');
    }
  }

  /// Clear widget data
  static Future<void> clearWidget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPhoto);
      await prefs.remove(_keyCaption);
      await prefs.remove(_keyUpdatedAt);
      await prefs.remove(_keyConnectionId);
      
      debugPrint('Widget data cleared');
    } catch (e) {
      debugPrint('Error clearing widget data: $e');
    }
  }

  /// Get current widget data
  static Future<WidgetData?> getWidgetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final connectionId = prefs.getString(_keyConnectionId);
      final photoBase64 = prefs.getString(_keyPhoto);
      final caption = prefs.getString(_keyCaption);
      final updatedAtStr = prefs.getString(_keyUpdatedAt);

      if (connectionId == null) return null;

      return WidgetData(
        connectionId: connectionId,
        photoBase64: photoBase64,
        caption: caption,
        updatedAt: updatedAtStr != null
            ? DateTime.parse(updatedAtStr)
            : null,
      );
    } catch (e) {
      debugPrint('Error getting widget data: $e');
      return null;
    }
  }
}

/// Widget data model
class WidgetData {
  final String connectionId;
  final String? photoBase64;
  final String? caption;
  final DateTime? updatedAt;

  WidgetData({
    required this.connectionId,
    this.photoBase64,
    this.caption,
    this.updatedAt,
  });

  Uint8List? get photoBytes {
    if (photoBase64 == null) return null;
    try {
      return base64Decode(photoBase64!);
    } catch (_) {
      return null;
    }
  }
}
