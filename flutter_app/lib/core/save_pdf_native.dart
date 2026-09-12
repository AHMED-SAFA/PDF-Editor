import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'api_client.dart';

Future<String> saveAndOpenPdf(PdfResult result) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, result.filename));
  await file.writeAsBytes(Uint8List.fromList(result.bytes), flush: true);
  await OpenFilex.open(file.path);
  return file.path;
}
