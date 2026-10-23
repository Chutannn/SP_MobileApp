import 'package:pdf/pdf.dart';

/// Supported paper sizes: A4 (210 x 297 mm) and F4 / Folio (215 x 330 mm).
/// Uses a super-thin 2.5 mm margin so the photo spans the full printable paper width.
enum PaperSizeOption {
  a4(
    label: 'A4',
    dimensionLabel: '210 x 297 mm',
    widthMm: 210,
    heightMm: 297,
    marginMm: 2.5,
  ),
  f4(
    label: 'F4',
    dimensionLabel: '215 x 330 mm',
    widthMm: 215,
    heightMm: 330,
    marginMm: 2.5,
  );

  const PaperSizeOption({
    required this.label,
    required this.dimensionLabel,
    required this.widthMm,
    required this.heightMm,
    required this.marginMm,
  });

  final String label;
  final String dimensionLabel;
  final double widthMm;
  final double heightMm;
  final double marginMm;

  double get aspectRatio => widthMm / heightMm;

  PdfPageFormat get pdfFormat => PdfPageFormat(
        widthMm * PdfPageFormat.mm,
        heightMm * PdfPageFormat.mm,
        marginAll: marginMm * PdfPageFormat.mm,
      );
}
