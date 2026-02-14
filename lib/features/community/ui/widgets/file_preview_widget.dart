import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/core.dart';

/// Widget for previewing and downloading file attachments
class FilePreviewWidget extends StatelessWidget {
  final String fileUrl;
  final String fileName;
  final int? fileSize;
  final bool isCurrentUser;

  const FilePreviewWidget({
    super.key,
    required this.fileUrl,
    required this.fileName,
    this.fileSize,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final fileExtension = _getFileExtension(fileName);
    final fileType = _getFileType(fileExtension);
    final iconData = _getFileIcon(fileType);
    final color = _getFileColor(fileType);

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? context.colors.primary.withOpacity(0.1)
            : context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? context.colors.primary.withOpacity(0.3)
              : context.colors.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              iconData,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      fileExtension.toUpperCase(),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (fileSize != null) ...[
                      Text(
                        ' • ',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _formatFileSize(fileSize!),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Download Button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.download_rounded,
                color: color,
                size: 20,
              ),
            ),
            onPressed: () => _handleFileAction(context),
          ),
        ],
      ),
    );
  }

  String _getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last : 'file';
  }

  FileType _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return FileType.pdf;
      case 'doc':
      case 'docx':
        return FileType.document;
      case 'xls':
      case 'xlsx':
        return FileType.spreadsheet;
      case 'ppt':
      case 'pptx':
        return FileType.presentation;
      case 'zip':
      case 'rar':
      case '7z':
        return FileType.archive;
      case 'txt':
        return FileType.text;
      default:
        return FileType.unknown;
    }
  }

  IconData _getFileIcon(FileType type) {
    switch (type) {
      case FileType.pdf:
        return Icons.picture_as_pdf_rounded;
      case FileType.document:
        return Icons.description_rounded;
      case FileType.spreadsheet:
        return Icons.table_chart_rounded;
      case FileType.presentation:
        return Icons.slideshow_rounded;
      case FileType.archive:
        return Icons.folder_zip_rounded;
      case FileType.text:
        return Icons.text_snippet_rounded;
      case FileType.unknown:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileColor(FileType type) {
    switch (type) {
      case FileType.pdf:
        return const Color(0xFFE53935); // Red
      case FileType.document:
        return const Color(0xFF1E88E5); // Blue
      case FileType.spreadsheet:
        return const Color(0xFF43A047); // Green
      case FileType.presentation:
        return const Color(0xFFFB8C00); // Orange
      case FileType.archive:
        return const Color(0xFF8E24AA); // Purple
      case FileType.text:
        return const Color(0xFF757575); // Gray
      case FileType.unknown:
        return const Color(0xFF546E7A); // Blue Gray
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _handleFileAction(BuildContext context) async {
    try {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackbar(context, 'Cannot open file');
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Error opening file: $e');
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

enum FileType {
  pdf,
  document,
  spreadsheet,
  presentation,
  archive,
  text,
  unknown,
}
