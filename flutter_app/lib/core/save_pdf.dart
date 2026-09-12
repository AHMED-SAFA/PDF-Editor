import 'dart:typed_data';

import 'api_client.dart';

export 'save_pdf_stub.dart'
    if (dart.library.io) 'save_pdf_native.dart'
    if (dart.library.html) 'save_pdf_web.dart';
