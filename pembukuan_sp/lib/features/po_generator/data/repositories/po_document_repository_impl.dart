import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../domain/entities/image_scale_preset.dart';
import '../../domain/entities/paper_size_option.dart';
import '../../domain/entities/po_image_item.dart';
import '../../domain/entities/store_target.dart';
import '../../domain/repositories/po_document_repository.dart';
import '../datasources/file_download_datasource.dart';
import '../datasources/image_processing_datasource.dart';
import '../datasources/pdf_builder_datasource.dart';

/// Concrete implementation of [PoDocumentRepository] coordinating image processing,
/// PDF generation, printer spooling, and file downloading.
class PoDocumentRepositoryImpl implements PoDocumentRepository {
  const PoDocumentRepositoryImpl({
    this.imageProcessingDataSource = const ImageProcessingDataSource(),
    this.pdfBuilderDataSource = const PdfBuilderDataSource(),
    this.fileDownloadDataSource = const FileDownloadDataSource(),
  });

  final ImageProcessingDataSource imageProcessingDataSource;
  final PdfBuilderDataSource pdfBuilderDataSource;
  final FileDownloadDataSource fileDownloadDataSource;

  @override
  Future<({Uint8List bytes, int width, int height})> normalizeImage(
    Uint8List rawBytes,
  ) {
    return imageProcessingDataSource.normalize(rawBytes);
  }

  @override
  Future<Uint8List> buildPdfBytes({
    required StoreTarget store,
    required PaperSizeOption paperSize,
    required List<PoImageItem> images,
    required DateTime createdAt,
    required ImageScalePreset scalePreset,
    PdfPageFormat? pageFormatOverride,
  }) {
    return pdfBuilderDataSource.buildPdfBytes(
      store: store,
      paperSize: paperSize,
      images: images,
      createdAt: createdAt,
      scalePreset: scalePreset,
      pageFormatOverride: pageFormatOverride,
    );
  }

  @override
  PdfPageFormat resolvePrintPageFormat({
    required PdfPageFormat printerFormat,
    required PaperSizeOption paperSize,
  }) {
    return pdfBuilderDataSource.resolvePrintPageFormat(
      printerFormat: printerFormat,
      paperSize: paperSize,
    );
  }

  @override
  Future<void> printPoDocument({
    required String fileName,
    required StoreTarget store,
    required PaperSizeOption paperSize,
    required List<PoImageItem> images,
    required ImageScalePreset scalePreset,
  }) async {
    await Printing.layoutPdf(
      name: fileName,
      format: paperSize.pdfFormat,
      usePrinterSettings: false,
      onLayout: (PdfPageFormat printerFormat) async {
        final targetFormat = resolvePrintPageFormat(
          printerFormat: printerFormat,
          paperSize: paperSize,
        );
        return buildPdfBytes(
          store: store,
          paperSize: paperSize,
          images: images,
          createdAt: DateTime.now(),
          scalePreset: scalePreset,
          pageFormatOverride: targetFormat,
        );
      },
    );
  }

  @override
  Future<String?> savePoPdfToDownloads({
    required String fileName,
    required Uint8List pdfBytes,
  }) {
    return fileDownloadDataSource.savePdfToDownloads(
      fileName: fileName,
      pdfBytes: pdfBytes,
    );
  }
}
