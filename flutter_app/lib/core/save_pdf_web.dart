// avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'api_client.dart';

Future<String> saveAndOpenPdf(PdfResult result) async {
  final bytes = Uint8List.fromList(result.bytes);
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', result.filename)
    ..click();
  html.Url.revokeObjectUrl(url);
  return result.filename;
}
