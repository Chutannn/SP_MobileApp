import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../core/theme/twilight_palette.dart';
import '../../../../core/theme/twilight_typography.dart';
import '../controllers/po_generator_controller.dart';
import '../widgets/po_bottom_action_bar.dart';
import '../widgets/po_image_input_section.dart';
import '../widgets/po_preview_section.dart';
import '../widgets/po_store_paper_section.dart';
import '../widgets/po_top_bar.dart';

class PoGeneratorScreen extends StatefulWidget {
  const PoGeneratorScreen({
    super.key,
    this.controller,
  });

  final PoGeneratorController? controller;

  @override
  State<PoGeneratorScreen> createState() => _PoGeneratorScreenState();
}

class _PoGeneratorScreenState extends State<PoGeneratorScreen> {
  late final PoGeneratorController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? PoGeneratorController();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleDownloadPo() async {
    final message = await _controller.downloadPo();
    if (!mounted || message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: TwilightPalette.surfaceAlt,
        content: Text(
          message,
          style:
              TwilightTypography.sans(size: 12, color: TwilightPalette.onSurface),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _openInteractivePdfPreviewModal() async {
    if (_controller.images.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TwilightPalette.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.86,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 14, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preview PDF PO',
                              style: TwilightTypography.serif(size: 17),
                            ),
                            Text(
                              '${_controller.selectedStore.name} · ${_controller.selectedPaper.label}',
                              style: TwilightTypography.sans(
                                size: 12,
                                color: TwilightPalette.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Tutup',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: TwilightPalette.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: TwilightPalette.border),
                Expanded(
                  child: PdfPreview(
                    initialPageFormat: _controller.selectedPaper.pdfFormat,
                    build: (PdfPageFormat format) =>
                        _controller.buildPdfBytesForPrinterFormat(format),
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    canDebug: false,
                    pdfFileName: _controller.buildFileName(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final pages = _controller.paginatedImages;

        return Column(
          children: [
            const PoTopBar(
              title: 'Buat File PO',
              subtitle: 'Sari Purnama',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                children: [
                  if (_controller.errorMessage != null) ...[
                    _buildErrorBanner(_controller.errorMessage!),
                    const SizedBox(height: 12),
                  ],
                  if (_controller.statusBanner != null) ...[
                    _buildStatusBanner(_controller.statusBanner!),
                    const SizedBox(height: 12),
                  ],
                  if (_controller.isBusy && _controller.busyMessage != null) ...[
                    _buildLoadingBanner(_controller.busyMessage!),
                    const SizedBox(height: 12),
                  ],
                  PoStorePaperSection(
                    selectedStore: _controller.selectedStore,
                    selectedPaper: _controller.selectedPaper,
                    selectedScale: _controller.selectedScale,
                    onSelectStore: _controller.selectStore,
                    onSelectPaper: _controller.selectPaper,
                    onSelectScale: _controller.selectScale,
                  ),
                  const SizedBox(height: 14),
                  PoImageInputSection(
                    images: _controller.images,
                    selectedStore: _controller.selectedStore,
                    isBusy: _controller.isBusy,
                    onPickGallery: _controller.pickImagesFromGallery,
                    onPickCamera: _controller.pickImageFromCamera,
                    onClearAll: _controller.clearAllImages,
                    onMoveImage: _controller.moveImage,
                    onRemoveImageAt: _controller.removeImageAt,
                  ),
                  const SizedBox(height: 14),
                  PoPreviewSection(
                    pages: pages,
                    selectedStore: _controller.selectedStore,
                    selectedPaper: _controller.selectedPaper,
                    selectedScale: _controller.selectedScale,
                    isBusy: _controller.isBusy,
                    onOpenInteractivePdfModal: _openInteractivePdfPreviewModal,
                  ),
                  const SizedBox(height: 16),
                  PoBottomActionBar(
                    hasImages: _controller.images.isNotEmpty,
                    isBusy: _controller.isBusy,
                    selectedPaper: _controller.selectedPaper,
                    onDownloadPo: _handleDownloadPo,
                    onPrintPo: _controller.printPo,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: TwilightPalette.destructive,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: TwilightPalette.destructiveText,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TwilightTypography.sans(
                size: 12,
                color: TwilightPalette.destructiveText,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Tutup',
            visualDensity: VisualDensity.compact,
            onPressed: _controller.clearError,
            icon: const Icon(
              Icons.close,
              size: 16,
              color: TwilightPalette.destructiveText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: TwilightPalette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TwilightPalette.accent),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: TwilightPalette.accent,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TwilightTypography.sans(
                size: 12,
                color: TwilightPalette.onSurface,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Tutup',
            visualDensity: VisualDensity.compact,
            onPressed: _controller.clearStatusBanner,
            icon: const Icon(
              Icons.close,
              size: 16,
              color: TwilightPalette.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: TwilightPalette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TwilightPalette.primary),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: TwilightPalette.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TwilightTypography.sans(
                size: 12,
                color: TwilightPalette.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
