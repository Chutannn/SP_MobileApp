import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

/// Data source handling native Android Download folder storage and system sharing.
class FileDownloadDataSource {
  const FileDownloadDataSource();

  static const MethodChannel _downloadsChannel =
      MethodChannel('com.example.pembukuan_sp/downloads');

  /// Saves the generated PO PDF directly into the user's phone Download folder
  /// (`/storage/emulated/0/Download/<fileName>`).
  Future<String?> savePdfToDownloads({
    required String fileName,
    required Uint8List pdfBytes,
  }) async {
    String? savedFilePath;

    if (!kIsWeb && Platform.isAndroid) {
      try {
        savedFilePath = await _downloadsChannel.invokeMethod<String>(
          'savePdfToDownloads',
          {
            'fileName': fileName,
            'bytes': pdfBytes,
          },
        );
      } catch (_) {
        // Fallback direct write to /storage/emulated/0/Download
        final directDir = Directory('/storage/emulated/0/Download');
        if (await directDir.exists()) {
          final file = File('${directDir.path}/$fileName');
          await file.writeAsBytes(pdfBytes, flush: true);
          savedFilePath = file.path;
        }
      }
    } else if (!kIsWeb) {
      Directory? targetDir;
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        targetDir = await getDownloadsDirectory();
      }
      targetDir ??= await getApplicationDocumentsDirectory();
      final file = File('${targetDir.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(pdfBytes, flush: true);
      savedFilePath = file.path;
    }

    if (savedFilePath == null) {
      await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
    }

    return savedFilePath;
  }
}
