import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pembukuan_sp/main.dart';

void main() {
  test(
      'Store pagination, paper size rules, printer format resolution, and PDF generation work as specified',
      () async {
    final items = ['img1', 'img2', 'img3'];

    final satuSamaPages =
        chunkImagesForPages(items, StoreTarget.satuSama.maxImagesPerPage);
    expect(satuSamaPages.length, 2);
    expect(satuSamaPages[0], ['img1', 'img2']);
    expect(satuSamaPages[1], ['img3']);

    final diamondPages =
        chunkImagesForPages(items, StoreTarget.diamond.maxImagesPerPage);
    expect(diamondPages.length, 3);
    expect(diamondPages[0], ['img1']);
    expect(diamondPages[1], ['img2']);
    expect(diamondPages[2], ['img3']);

    expect(PaperSizeOption.a4.widthMm, 210);
    expect(PaperSizeOption.a4.heightMm, 297);
    expect(PaperSizeOption.f4.widthMm, 215);
    expect(PaperSizeOption.f4.heightMm, 330);

    const pdfDataSource = PdfBuilderDataSource();
    final resolvedFormat = pdfDataSource.resolvePrintPageFormat(
      printerFormat: PdfPageFormat.letter,
      paperSize: PaperSizeOption.f4,
    );
    expect(resolvedFormat.width, PdfPageFormat.letter.width);
    expect(resolvedFormat.height, PdfPageFormat.letter.height);

    // Valid 1x1 transparent PNG bytes
    final pngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
    );
    final pdfBytes = await buildPoPdfBytes(
      store: StoreTarget.satuSama,
      paperSize: PaperSizeOption.f4,
      images: [
        PoImageItem(id: '1', name: 'po_1.png', bytes: pngBytes),
        PoImageItem(id: '2', name: 'po_2.png', bytes: pngBytes),
      ],
      createdAt: DateTime(2026, 10, 23, 19, 0),
    );
    expect(pdfBytes.isNotEmpty, isTrue);
    expect(String.fromCharCodes(pdfBytes.take(4)), '%PDF');
  });

  test('PoGeneratorController manages store, paper, and scale state cleanly',
      () {
    final controller = PoGeneratorController();
    expect(controller.selectedStore, StoreTarget.satuSama);
    expect(controller.selectedPaper, PaperSizeOption.a4);
    expect(controller.selectedScale, ImageScalePreset.fullMax);

    controller.selectStore(StoreTarget.diamond);
    expect(controller.selectedStore, StoreTarget.diamond);

    controller.selectPaper(PaperSizeOption.f4);
    expect(controller.selectedPaper, PaperSizeOption.f4);

    controller.selectScale(ImageScalePreset.fullWidth);
    expect(controller.selectedScale, ImageScalePreset.fullWidth);
    controller.dispose();
  });

  testWidgets(
      'Sari Purnama Homepage, floating bottom bar, and 3 PO form dropdowns work cleanly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(540, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SariPurnamaApp());

    // Verify Homepage (Beranda) only shows Menu Utama
    expect(find.text('Sari Purnama'), findsWidgets);
    expect(find.text('Menu Utama'), findsOneWidget);
    expect(find.text('Buat File PO'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Buat PO'), findsOneWidget);

    // Navigate to Buat PO page via floating bottom bar
    await tester.tap(find.text('Buat PO'));
    await tester.pumpAndSettle();

    expect(find.text('Form Pengaturan PO'), findsOneWidget);
    expect(find.text('Pilih Toko'), findsOneWidget);
    expect(find.text('Ukuran Kertas'), findsOneWidget);
    expect(find.text('Ukuran Foto di Kertas'), findsOneWidget);
    expect(find.text('Pilih Gambar'), findsOneWidget);
    expect(find.text('Kamera'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Print (A4)'), findsOneWidget);

    // Open Ukuran Kertas dropdown and select F4
    await tester.tap(find.text('A4 (210 x 297 mm)').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('F4 (215 x 330 mm)').last);
    await tester.pumpAndSettle();

    expect(find.text('Print (F4)'), findsOneWidget);
  });
}
