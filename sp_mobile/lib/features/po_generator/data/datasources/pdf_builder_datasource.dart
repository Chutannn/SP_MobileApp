import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/utils/pagination_utils.dart';
import '../../domain/entities/image_scale_preset.dart';
import '../../domain/entities/paper_size_option.dart';
import '../../domain/entities/po_image_item.dart';
import '../../domain/entities/store_target.dart';

/// Builds the printable PO PDF document bytes from the selected store, paper size, and images.
///
/// Ensures every image spans the full printable page width while staying 100%
/// within the slot height so nothing is ever cut off.
Future<Uint8List> buildPoPdfBytes({
  required StoreTarget store,
  required PaperSizeOption paperSize,
  required List<PoImageItem> images,
  required DateTime createdAt,
  ImageScalePreset scalePreset = ImageScalePreset.fullMax,
  PdfPageFormat? pageFormatOverride,
}) async {
  final doc = pw.Document(
    title: 'PO ${store.name} (${paperSize.label})',
    author: 'Pembukuan SP',
  );

  final pages = chunkImagesForPages(images, store.maxImagesPerPage);
  final dateStr = DateFormat('dd/MM/yyyy').format(createdAt);
  final pageFormat = pageFormatOverride ?? paperSize.pdfFormat;
  final widthFactor = scalePreset.widthFactor.clamp(0.5, 1.0);
  final heightBoost = scalePreset.heightBoost.clamp(1.0, 1.35);

  for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
    final pageImages = pages[pageIndex];
    final memoryImages =
        pageImages.map((item) => pw.MemoryImage(item.bytes)).toList();

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Thin header at the top of the sheet
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 2),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(
                      color: PdfColors.grey700,
                      width: 0.5,
                    ),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'PURCHASE ORDER (PO)  |  TOKO ${store.name.toUpperCase()}',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      '$dateStr  |  Hal. ${pageIndex + 1}/${pages.length}',
                      style: const pw.TextStyle(
                        fontSize: 7.5,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 2),
              // Image slots below the thin header
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    for (int slot = 0; slot < memoryImages.length; slot++) ...[
                      if (slot > 0) pw.SizedBox(height: 4),
                      pw.Expanded(
                        child: pw.LayoutBuilder(
                          builder: (
                            pw.Context ctx,
                            pw.BoxConstraints? constraints,
                          ) {
                            final double maxSlotW = constraints?.maxWidth ??
                                pageFormat.availableWidth;
                            final double maxSlotH = constraints?.maxHeight ??
                                (pageFormat.availableHeight - 16) /
                                    memoryImages.length;

                            final double targetW = maxSlotW * widthFactor;
                            final double imgRatio =
                                pageImages[slot].aspectRatio;
                            final double proportionalH =
                                (targetW / imgRatio) * heightBoost;
                            final double targetH = proportionalH <= maxSlotH
                                ? proportionalH
                                : maxSlotH;

                            return pw.Container(
                              width: maxSlotW,
                              height: maxSlotH,
                              alignment: pw.Alignment.center,
                              child: scalePreset.stretchToWidth
                                  ? pw.Image(
                                      memoryImages[slot],
                                      fit: pw.BoxFit.fill,
                                      width: targetW,
                                      height: targetH,
                                      alignment: pw.Alignment.center,
                                    )
                                  : pw.Image(
                                      memoryImages[slot],
                                      fit: pw.BoxFit.contain,
                                      width: targetW,
                                      height: maxSlotH,
                                      alignment: pw.Alignment.center,
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  return doc.save();
}

/// Data source responsible for PDF generation and printer page format matching.
class PdfBuilderDataSource {
  const PdfBuilderDataSource();

  /// Resolves the exact target paper format requested by Android's print service
  /// so the printer never downscales ("Fit to Page") an F4/A4 PDF onto A4/Letter.
  PdfPageFormat resolvePrintPageFormat({
    required PdfPageFormat printerFormat,
    required PaperSizeOption paperSize,
  }) {
    final double marginPt = paperSize.marginMm * PdfPageFormat.mm;
    if (printerFormat.width > 100 && printerFormat.height > 100) {
      return PdfPageFormat(
        printerFormat.width,
        printerFormat.height,
        marginAll: marginPt,
      );
    }
    return paperSize.pdfFormat;
  }

  Future<Uint8List> buildPdfBytes({
    required StoreTarget store,
    required PaperSizeOption paperSize,
    required List<PoImageItem> images,
    required DateTime createdAt,
    required ImageScalePreset scalePreset,
    PdfPageFormat? pageFormatOverride,
  }) =>
      buildPoPdfBytes(
        store: store,
        paperSize: paperSize,
        images: images,
        createdAt: createdAt,
        scalePreset: scalePreset,
        pageFormatOverride: pageFormatOverride,
      );
}
