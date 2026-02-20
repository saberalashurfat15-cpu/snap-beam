import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Backend service for SnapBeam API communication
/// Configured to work with Cloudflare Workers backend
class BackendService {
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  // TODO: Replace with your Cloudflare Workers URL
  // Example: https://snapbeam-api.your-subdomain.workers.dev
  static const String baseUrl = 'https://snapbeam-api.example.workers.dev';

  final http.Client _client = http.Client();

  /// Create a new connection
  /// Returns the connection ID
  Future<String> createConnection() async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['connection_id'] as String;
      } else {
        throw Exception('Failed to create connection: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update photo for a connection
  /// Can use either photo_url or photo_base64
  Future<void> updatePhoto({
    required String connectionId,
    String? photoUrl,
    String? photoBase64,
    String? caption,
  }) async {
    try {
      final body = <String, dynamic>{
        'connection_id': connectionId,
      };

      if (photoUrl != null) body['photo_url'] = photoUrl;
      if (photoBase64 != null) body['photo_base64'] = photoBase64;
      if (caption != null) body['caption'] = caption;

      final response = await _client.post(
        Uri.parse('$baseUrl/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update photo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get latest photo for a connection
  Future<PhotoData?> getLatestPhoto(String connectionId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/latest?connection_id=$connectionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return PhotoData(
            photoUrl: data['last_photo_url'] as String?,
            photoBase64: data['last_photo_base64'] as String?,
            caption: data['last_caption'] as String?,
            updatedAt: data['updated_at'] != null
                ? DateTime.parse(data['updated_at'])
                : null,
          );
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get photo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Upload photo to R2 storage
  Future<String> uploadPhoto({
    required String connectionId,
    required File photoFile,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload'),
      );

      request.fields['connection_id'] = connectionId;
      request.files.add(
        await http.MultipartFile.fromPath('photo', photoFile.path),
      );

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['photo_url'] as String;
      } else {
        throw Exception('Failed to upload photo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  /// Delete a connection
  Future<void> deleteConnection(String connectionId) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'connection_id': connectionId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete connection: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/health'),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

/// Photo data model
class PhotoData {
  final String? photoUrl;
  final String? photoBase64;
  final String? caption;
  final DateTime? updatedAt;

  PhotoData({
    this.photoUrl,
    this.photoBase64,
    this.caption,
    this.updatedAt,
  });

  bool get hasPhoto => photoUrl != null || photoBase64 != null;
}
