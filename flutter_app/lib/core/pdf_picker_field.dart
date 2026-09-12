import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PdfPickerField extends StatefulWidget {
  final PlatformFile? file;
  final ValueChanged<PlatformFile> onPicked;

  const PdfPickerField({
    super.key,
    required this.file,
    required this.onPicked,
  });

  @override
  State<PdfPickerField> createState() => _PdfPickerFieldState();
}

class _PdfPickerFieldState extends State<PdfPickerField> {
  bool _isHovered = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      widget.onPicked(result.files.first);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.file != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _pickFile,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 150),
          width: double.infinity,
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.colorScheme.primary.withOpacity(0.08)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.5),
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          child: CustomPaint(
            painter: !isSelected && !_isHovered
                ? _DashedBorderPainter(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                    borderRadius: 16,
                  )
                : null,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: isSelected ? _buildSelectedState(theme) : _buildEmptyState(theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.picture_as_pdf_outlined,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Tap to select a PDF',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Supports .pdf files',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSelectedState(ThemeData theme) {
    final file = widget.file!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            color: theme.colorScheme.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          file.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        if (file.size > 0)
          Text(
            _formatBytes(file.size),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Change file'),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    // A simple dashed path effect
    final dashPath = Path();
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
  }
}
