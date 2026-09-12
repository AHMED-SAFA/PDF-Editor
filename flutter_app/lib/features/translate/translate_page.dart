import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/pdf_picker_field.dart';
import '../../core/save_pdf.dart';

const Map<String, String> languages = {
  'en': 'English (en)',
  'bn': 'Bangla (bn)',
  'hi': 'Hindi (hi)',
  'ar': 'Arabic (ar)',
  'es': 'Spanish (es)',
  'fr': 'French (fr)',
};

class TranslatePage extends StatefulWidget {
  final PdfApiClient client;

  const TranslatePage({super.key, required this.client});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  String _sourceLang = 'en';
  String _targetLang = 'bn';

  PlatformFile? _selectedFile;
  bool _isTranslating = false;
  PdfResult? _result;

  Future<void> _translate() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first.')),
      );
      return;
    }

    final bytes = _selectedFile!.bytes;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read file data.')),
      );
      return;
    }

    setState(() {
      _isTranslating = true;
      _result = null;
    });

    try {
      final res = await widget.client.translatePdf(
        fileBytes: bytes,
        filename: _selectedFile!.name,
        sourceLanguage: _sourceLang,
        targetLanguage: _targetLang,
      );

      if (mounted) {
        setState(() {
          _result = res;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Translation completed successfully!')),
        );
      }
    } on PdfApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation failed: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Translation failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
      }
    }
  }

  void _downloadResult() {
    if (_result != null) {
      saveAndOpenPdf(_result!);
    }
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
              const SizedBox(height: 16),
              _buildSectionHeader('Upload Document', Icons.cloud_upload_outlined),
              const SizedBox(height: 12),
              PdfPickerField(
                file: _selectedFile,
                onPicked: (file) {
                  setState(() {
                    _selectedFile = file;
                    _result = null;
                  });
                },
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Language Settings', Icons.translate),
              const SizedBox(height: 12),
              _buildLanguageSelectors(),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isTranslating
                    ? const _LoadingIndicator()
                    : _buildTranslateButton(),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: _result != null
                    ? _buildSuccessCard()
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelectors() {
    return Row(
      children: [
        Expanded(
          child: _LanguageDropdown(
            label: 'Source',
            value: _sourceLang,
            items: languages,
            onChanged: (val) {
              if (val != null) setState(() => _sourceLang = val);
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(Icons.swap_horiz, color: Colors.grey),
        ),
        Expanded(
          child: _LanguageDropdown(
            label: 'Target',
            value: _targetLang,
            items: languages,
            onChanged: (val) {
              if (val != null) setState(() => _targetLang = val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTranslateButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _translate,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Translate Document',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Card(
      key: const ValueKey('success'),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E1E1E),
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Translation Ready',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _result?.filename ?? 'translated.pdf',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildDownloadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF00b09b), Color(0xFF96c93d)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00b09b).withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _downloadResult,
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Download PDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  const _LanguageDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.language, color: Colors.grey),
          dropdownColor: const Color(0xFF2A2A2A),
          style: const TextStyle(color: Colors.white, fontSize: 15),
          items: items.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
          ),
          SizedBox(height: 16),
          Text(
            'Translating your document...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
