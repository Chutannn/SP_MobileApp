import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import '../entities/image_scale_preset.dart';
import '../entities/paper_size_option.dart';
import '../entities/po_image_item.dart';
import '../entities/store_target.dart';

/// Repository contract for PO image normalization, PDF generation, printing, and saving.
abstract class PoDocumentRepository {
  /// Normalizes raw image bytes (EXIF orientation + auto-trimming excess white borders).
  Future<({Uint8List bytes, int width, int height})> normalizeImage(
    Uint8List rawBytes,
  );

  /// Builds the printable PO PDF document bytes.
  Future<Uint8List> buildPdfBytes({
    required StoreTarget store,
    required PaperSizeOption paperSize,
    required List<PoImageItem> images,
    required DateTime createdAt,
    required ImageScalePreset scalePreset,
    PdfPageFormat? pageFormatOverride,
  });

  /// Resolves the printer's target page format so Android Print Spooler does not shrink pages.
  PdfPageFormat resolvePrintPageFormat({
    required PdfPageFormat printerFormat,
    required PaperSizeOption paperSize,
  });

  /// Sends the PO document to the system print dialog (Wi-Fi / USB home printer).
  Future<void> printPoDocument({
    required String fileName,
    required StoreTarget store,
    required PaperSizeOption paperSize,
    required List<PoImageItem> images,
    required ImageScalePreset scalePreset,
  });

  /// Saves the generated PO PDF to the user's Download folder (or shares if unavailable).
  /// Returns the saved file path if written directly to storage.
  Future<String?> savePoPdfToDownloads({
    required String fileName,
    required Uint8List pdfBytes,
  });
}
