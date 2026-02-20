import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../services/backend_service.dart';
import '../services/widget_service.dart';

/// Connection state management provider
/// Handles connection creation, joining, and photo synchronization
class ConnectionProvider extends ChangeNotifier {
  String? _connectionId;
  PhotoData? _lastPhoto;
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get connectionId => _connectionId;
  PhotoData? get lastPhoto => _lastPhoto;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _connectionId != null;

  final BackendService _backendService = BackendService();

  /// Initialize provider from saved state
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _connectionId = prefs.getString('connection_id');
    
    if (_connectionId != null) {
      // Fetch latest photo
      await refreshPhoto();
    }
    
    notifyListeners();
  }

  /// Create a new connection
  Future<void> createConnection() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _connectionId = await _backendService.createConnection();
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('connection_id', _connectionId!);
      
      // Update widget
      await WidgetService.updateWidget(connectionId: _connectionId!);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Join existing connection with code
  Future<void> joinConnection(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Verify connection exists
      final photoData = await _backendService.getLatestPhoto(code);
      
      if (photoData == null && !await _backendService.healthCheck()) {
        throw Exception('Network error. Please check your connection.');
      }

      _connectionId = code.toUpperCase();
      _lastPhoto = photoData;

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('connection_id', _connectionId!);

      // Update widget
      await WidgetService.updateWidget(
        connectionId: _connectionId!,
        photoBase64: photoData?.photoBase64,
        caption: photoData?.caption,
        updatedAt: photoData?.updatedAt,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Refresh latest photo from server
  Future<void> refreshPhoto() async {
    if (_connectionId == null) return;

    try {
      _lastPhoto = await _backendService.getLatestPhoto(_connectionId!);
      
      if (_lastPhoto != null) {
        await WidgetService.updateWidget(
          connectionId: _connectionId!,
          photoBase64: _lastPhoto!.photoBase64,
          caption: _lastPhoto!.caption,
          updatedAt: _lastPhoto!.updatedAt,
        );
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Disconnect and clear connection
  Future<void> disconnect() async {
    _connectionId = null;
    _lastPhoto = null;
    _error = null;

    // Clear preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('connection_id');

    // Clear widget
    await WidgetService.clearWidget();

    notifyListeners();
  }

  /// Share connection code
  Future<void> shareCode() async {
    if (_connectionId == null) return;
    
    // This would use share_plus package
    // await Share.share('Join my SnapBeam: $_connectionId');
  }
}
