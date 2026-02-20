import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Photo widget display component
/// Shows the latest shared photo with caption
class PhotoWidget extends StatelessWidget {
  final String? photoBase64;
  final String? caption;
  final DateTime? updatedAt;
  final VoidCallback? onTap;

  const PhotoWidget({
    super.key,
    this.photoBase64,
    this.caption,
    this.updatedAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo or placeholder
              _buildPhotoContent(),
              
              // Caption overlay
              if (caption != null && caption!.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      caption!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              
              // Timestamp
              if (updatedAt != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatTime(updatedAt!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoContent() {
    if (photoBase64 != null && photoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(photoBase64!);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF6366F1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_rounded,
            size: 48,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 8),
          Text(
            'Waiting for photo...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// Widget refresh configuration
class WidgetRefreshConfig {
  final Duration interval;
  final bool enabled;

  const WidgetRefreshConfig({
    this.interval = const Duration(minutes: 5),
    this.enabled = true,
  });
}

/// Widget size configuration
enum WidgetSize {
  small,
  medium,
  large,
}

/// Get widget dimensions based on size
Map<String, double> getWidgetDimensions(WidgetSize size) {
  switch (size) {
    case WidgetSize.small:
      return {'width': 180.0, 'height': 180.0};
    case WidgetSize.medium:
      return {'width': 270.0, 'height': 180.0};
    case WidgetSize.large:
      return {'width': 270.0, 'height': 270.0};
  }
}
