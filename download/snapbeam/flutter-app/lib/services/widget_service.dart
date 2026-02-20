import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

/// Widget service for managing home screen widgets
/// Supports both Android and iOS widgets
class WidgetService {
  static const String _androidProviderName = 'SnapBeamWidgetProvider';
  static const String _widgetIdKey = 'connection_id';
  static const String _photoKey = 'last_photo';
  static const String _captionKey = 'last_caption';
  static const String _updatedAtKey = 'updated_at';

  /// Initialize widget service
  static Future<void> initialize() async {
    // Check if widget is launched
    final widgetInfo = await HomeWidget.getWidgetData(_widgetIdKey);
    if (widgetInfo != null) {
      debugPrint('Widget launched with connection: $widgetInfo');
    }
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
      // Save connection ID for widget
      await HomeWidget.saveWidgetData(
        _widgetIdKey,
        connectionId,
      );

      // Save photo (prefer base64 for offline support)
      if (photoBase64 != null) {
        await HomeWidget.saveWidgetData(_photoKey, photoBase64);
      }

      // Save caption
      if (caption != null) {
        await HomeWidget.saveWidgetData(_captionKey, caption);
      }

      // Save update time
      if (updatedAt != null) {
        await HomeWidget.saveWidgetData(
          _updatedAtKey,
          updatedAt.toIso8601String(),
        );
      }

      // Update Android widget
      await HomeWidget.updateWidget(
        name: _androidProviderName,
        iOSName: 'SnapBeamWidget',
        androidName: _androidProviderName,
      );

      debugPrint('Widget updated successfully');
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }

  /// Clear widget data
  static Future<void> clearWidget() async {
    try {
      await HomeWidget.saveWidgetData(_widgetIdKey, null);
      await HomeWidget.saveWidgetData(_photoKey, null);
      await HomeWidget.saveWidgetData(_captionKey, null);
      await HomeWidget.saveWidgetData(_updatedAtKey, null);

      await HomeWidget.updateWidget(
        name: _androidProviderName,
        iOSName: 'SnapBeamWidget',
        androidName: _androidProviderName,
      );
    } catch (e) {
      debugPrint('Error clearing widget: $e');
    }
  }

  /// Get current widget data
  static Future<WidgetData?> getWidgetData() async {
    try {
      final connectionId = await HomeWidget.getWidgetData(_widgetIdKey);
      final photoBase64 = await HomeWidget.getWidgetData(_photoKey);
      final caption = await HomeWidget.getWidgetData(_captionKey);
      final updatedAtStr = await HomeWidget.getWidgetData(_updatedAtKey);

      if (connectionId == null) return null;

      return WidgetData(
        connectionId: connectionId.toString(),
        photoBase64: photoBase64?.toString(),
        caption: caption?.toString(),
        updatedAt: updatedAtStr != null
            ? DateTime.parse(updatedAtStr.toString())
            : null,
      );
    } catch (e) {
      debugPrint('Error getting widget data: $e');
      return null;
    }
  }

  /// Register callback for widget interactions
  static Future<void> registerCallback(
    void Function(Uri?) callback,
  ) async {
    await HomeWidget.registerInteractivityCallback(
      (uri) => callback(uri),
    );
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
