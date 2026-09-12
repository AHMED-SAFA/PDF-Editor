import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'api_config.dart';

class PdfResult {
  const PdfResult({required this.bytes, required this.filename});

  final List<int> bytes;
  final String filename;
}

class PdfApiClient {
  PdfApiClient({ApiConfig config = ApiConfig.current, Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: config.baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(minutes: 2),
                sendTimeout: const Duration(minutes: 2),
              ),
            );

  final Dio _dio;

  Future<PdfResult> translatePdf({
    required Uint8List fileBytes,
    required String filename,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    return _postPdf(
      '/api/translate-pdf',
      FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: filename),
        'source_language': sourceLanguage,
        'target_language': targetLanguage,
      }),
      fallbackName: 'translated.pdf',
    );
  }

  Future<PdfResult> watermarkPdf({
    required Uint8List fileBytes,
    required String filename,
    required String text,
    required String position,
    required double opacity,
    required String color,
  }) {
    return _postPdf(
      '/editor/pdf/watermark',
      FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: filename),
        'text': text,
        'position': position,
        'opacity': opacity.toString(),
        'color': color,
      }),
      fallbackName: 'watermarked.pdf',
    );
  }

  Future<PdfResult> _postPdf(
    String path,
    FormData data,
    {required String fallbackName}
  ) async {
    try {
      final response = await _dio.post<List<int>>(
        path,
        data: data,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data ?? <int>[];
      if (bytes.isEmpty) {
        throw const PdfApiException('Server returned an empty file.');
      }
      return PdfResult(
        bytes: bytes,
        filename: _filenameFrom(response.headers.value('content-disposition'), fallbackName),
      );
    } on DioException catch (error) {
      throw PdfApiException(_messageFrom(error));
    }
  }

  String _filenameFrom(String? header, String fallback) {
    if (header == null) return fallback;
    final match = RegExp(r'filename="?([^"]+)"?').firstMatch(header);
    return match?.group(1) ?? fallback;
  }

  String _messageFrom(DioException error) {
    final data = error.response?.data;
    if (data is List<int>) {
      final text = String.fromCharCodes(data);
      final detail = RegExp(r'"detail"\s*:\s*"([^"]+)"').firstMatch(text);
      if (detail != null) return detail.group(1)!;
    }
    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }
    return error.message ?? 'Request failed.';
  }
}

class PdfApiException implements Exception {
  const PdfApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
