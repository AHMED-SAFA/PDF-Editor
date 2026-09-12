import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/pdf_picker_field.dart';
import '../../core/save_pdf.dart';

class WatermarkPage extends StatefulWidget {
  final PdfApiClient client;

  const WatermarkPage({
    super.key,
    required this.client,
  });

  @override
  State<WatermarkPage> createState() => _WatermarkPageState();
}

class _WatermarkPageState extends State<WatermarkPage> {
  PlatformFile? _selectedFile;
  bool _isLoading = false;
  PdfResult? _result;

  final TextEditingController _textController = TextEditingController(text: 'CONFIDENTIAL');
  final TextEditingController _colorController = TextEditingController(text: '#FF0000');

  String _position = 'center';
  double _opacity = 0.5;

  static const List<String> _positions = [
    'top-left', 'top-center', 'top-right',
    'center',
    'bottom-left', 'bottom-center', 'bottom-right'
  ];

  static const List<String> _colorPresets = [
    '#FF0000', '#00FF00', '#0000FF', '#FFFF00',
    '#FF00FF', '#00FFFF', '#000000', '#FFFFFF',
    '#808080', '#FFA500'
  ];

  @override
  void dispose() {
    _textController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hexStr) {
    String hex = hexStr.replaceAll('#', '').toUpperCase();
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length != 8) {
      return Colors.transparent;
    }
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.transparent;
    }
  }

  Future<void> _applyWatermark() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first.')),
      );
      return;
    }
    if (_selectedFile!.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File contents are empty.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final res = await widget.client.watermarkPdf(
        fileBytes: _selectedFile!.bytes!,
        filename: _selectedFile!.name,
        text: _textController.text.isEmpty ? 'CONFIDENTIAL' : _textController.text,
        position: _position,
        opacity: _opacity,
        color: _colorController.text,
      );

      setState(() {
        _result = res;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Watermark applied successfully!')),
        );
      }
    } on PdfApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // File Selection Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Document', Icons.description_outlined),
                    PdfPickerField(
                      file: _selectedFile,
                      onPicked: (file) {
                        setState(() {
                          _selectedFile = file;
                          _result = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Content Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Content', Icons.text_fields),
                    TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Watermark Text',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: const Icon(Icons.water_drop, color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.cyanAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Appearance Card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Appearance', Icons.palette_outlined),

                    // Position selection
                    Text('Position', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _positions.map((pos) {
                        final isSelected = _position == pos;
                        return ChoiceChip(
                          label: Text(pos.replaceAll('-', ' ')),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _position = pos);
                          },
                          backgroundColor: Colors.white.withOpacity(0.05),
                          selectedColor: Colors.cyan.withOpacity(0.2),
                          side: BorderSide(
                            color: isSelected ? Colors.cyanAccent : Colors.white.withOpacity(0.1),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.cyanAccent : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Opacity Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Opacity', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                        Text('${(_opacity * 100).toInt()}%',
                          style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.cyanAccent,
                        inactiveTrackColor: Colors.white.withOpacity(0.1),
                        thumbColor: Colors.cyanAccent,
                        overlayColor: Colors.cyanAccent.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _opacity,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        onChanged: (val) {
                          setState(() => _opacity = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Color selection
                    Text('Color', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _colorController,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (val) => setState(() {}),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.color_lens, color: _hexToColor(_colorController.text)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _colorPresets.map((colorHex) {
                        final color = _hexToColor(colorHex);
                        final isSelected = _colorController.text.toUpperCase() == colorHex.toUpperCase();
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _colorController.text = colorHex;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.cyanAccent : Colors.white24,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: color.withOpacity(0.6),
                                    blurRadius: 8,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Actions
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  key: ValueKey<bool>(_result != null),
                  children: [
                    // Apply Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8E2DE2).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _applyWatermark,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_fix_high, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Apply Watermark',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    // Download Button (Only shows if result exists)
                    if (_result != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF11998E).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_result != null) {
                              saveAndOpenPdf(_result!);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download_rounded, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Download Result',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
