import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// A reusable widget for displaying cached network images with loading and error states.
///
/// This widget uses [CachedNetworkImage] to cache images for better performance
/// and provides customizable loading and error widgets.
///
/// IMPORTANT: Pass the full image URL (e.g., '${ApiConstants.baseUrl}/uploads/image.jpg')
///
/// Example:
/// ```dart
/// CachedNetworkImageWidget(
///   imageUrl: '${ApiConstants.baseUrl}/uploads/images/profile.jpg',
///   height: 200,
///   width: 200,
///   borderRadius: 12,
///   fit: BoxFit.cover,
/// )
/// ```
class CachedNetworkImageWidget extends StatelessWidget {
  /// The full URL of the image (must include base URL if needed)
  final String imageUrl;

  /// The height of the image container
  final double? height;

  /// The width of the image container
  final double? width;

  /// How the image should be inscribed into the container
  final BoxFit fit;

  /// Border radius for the image container
  final double? borderRadius;

  /// Whether to show a skeleton loading effect
  final bool showSkeleton;

  /// Custom placeholder widget (overrides skeleton if provided)
  final Widget? placeholder;

  /// Custom error widget (overrides default error widget if provided)
  final Widget? errorWidget;

  /// Background color for the image container
  final Color? backgroundColor;

  const CachedNetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.showSkeleton = true,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) {
          if (placeholder != null) return placeholder!;

          if (showSkeleton) {
            return _buildSkeletonPlaceholder(isDark);
          }

          return _buildDefaultPlaceholder(isDark);
        },
        errorWidget: (context, url, error) {
          if (errorWidget != null) return errorWidget!;
          return _buildErrorWidget(isDark);
        },
      ),
    );
  }

  Widget _buildSkeletonPlaceholder(bool isDark) {
    return Skeletonizer(
      enabled: true,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
        ),
      ),
    );
  }

  Widget _buildDefaultPlaceholder(bool isDark) {
    return Container(
      height: height,
      width: width,
      color:
          backgroundColor ??
          (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? Colors.white60 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Container(
      height: height,
      width: width,
      color:
          backgroundColor ??
          (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: TextStyle(
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// A variant of [CachedNetworkImageWidget] specifically for circular avatars.
///
/// IMPORTANT: Pass the full image URL (e.g., '${ApiConstants.baseUrl}/uploads/avatar.jpg')
///
/// Example:
/// ```dart
/// CachedAvatarWidget(
///   imageUrl: '${ApiConstants.baseUrl}/uploads/avatars/user123.jpg',
///   radius: 40,
///   fallbackText: 'A',
/// )
/// ```
class CachedAvatarWidget extends StatelessWidget {
  /// The full URL of the avatar image
  final String? imageUrl;

  /// The radius of the circular avatar
  final double radius;

  /// Fallback text to display if image fails to load (usually user initials)
  final String? fallbackText;

  /// Fallback icon to display if no image and no text
  final IconData fallbackIcon;

  /// Background color for the avatar
  final Color? backgroundColor;

  const CachedAvatarWidget({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.fallbackText,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If no image URL, show fallback
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallbackAvatar(theme);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ?? theme.primaryColor.withValues(alpha: 0.1),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          height: radius * 2,
          width: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: SizedBox(
              width: radius * 0.6,
              height: radius * 0.6,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildFallbackAvatar(theme),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ?? theme.primaryColor.withValues(alpha: 0.1),
      child: fallbackText != null && fallbackText!.isNotEmpty
          ? Text(
              fallbackText!.toUpperCase(),
              style: TextStyle(
                fontSize: radius * 0.6,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            )
          : Icon(fallbackIcon, size: radius * 0.8, color: theme.primaryColor),
    );
  }
}

/// A variant for displaying images with parallax/hero effect.
///
/// IMPORTANT: Pass the full image URL (e.g., '${ApiConstants.baseUrl}/uploads/course.jpg')
///
/// Example:
/// ```dart
/// CachedHeroImageWidget(
///   imageUrl: '${ApiConstants.baseUrl}/uploads/courses/course123.jpg',
///   heroTag: 'course_123',
///   height: 200,
///   onTap: () => Navigator.push(...),
/// )
/// ```
class CachedHeroImageWidget extends StatelessWidget {
  /// The full URL of the image
  final String imageUrl;

  /// Unique tag for hero animation
  final String heroTag;

  /// Height of the image
  final double? height;

  /// Width of the image
  final double? width;

  /// Border radius
  final double? borderRadius;

  /// Callback when image is tapped
  final VoidCallback? onTap;

  const CachedHeroImageWidget({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.height,
    this.width,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: onTap,
        child: CachedNetworkImageWidget(
          imageUrl: imageUrl,
          height: height,
          width: width,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
