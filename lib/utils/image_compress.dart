import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Image compression utility for optimizing photos before upload
class ImageCompress {
  /// Compress image from bytes
  static Future<Uint8List?> compressBytes(
    Uint8List bytes, {
    int minWidth = 800,
    int minHeight = 800,
    int quality = 80,
  }) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minHeight: minHeight,
        minWidth: minWidth,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (e) {
      print('Compression error: $e');
      return null;
    }
  }

  /// Compress image from file path
  static Future<Uint8List?> compressFile(
    String path, {
    int minWidth = 800,
    int minHeight = 800,
    int quality = 80,
  }) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        path,
        minHeight: minHeight,
        minWidth: minWidth,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (e) {
      print('Compression error: $e');
      return null;
    }
  }

  /// Compress to specific size target (in bytes)
  static Future<Uint8List?> compressToSize(
    Uint8List bytes, {
    int targetSize = 500 * 1024, // 500KB default
  }) async {
    int quality = 85;
    Uint8List? result;

    while (quality > 10) {
      result = await compressBytes(bytes, quality: quality);
      if (result != null && result.length <= targetSize) {
        return result;
      }
      quality -= 5;
    }

    return result;
  }
}
