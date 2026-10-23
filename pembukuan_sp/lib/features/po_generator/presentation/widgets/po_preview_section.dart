import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/twilight_palette.dart';
import '../../../../core/theme/twilight_typography.dart';
import '../../domain/entities/image_scale_preset.dart';
import '../../domain/entities/paper_size_option.dart';
import '../../domain/entities/po_image_item.dart';
import '../../domain/entities/store_target.dart';

class PoPreviewSection extends StatelessWidget {
  const PoPreviewSection({
    super.key,
    required this.pages,
    required this.selectedStore,
    required this.selectedPaper,
    required this.selectedScale,
    required this.isBusy,
    required this.onOpenInteractivePdfModal,
  });

  final List<List<PoImageItem>> pages;
  final StoreTarget selectedStore;
  final PaperSizeOption selectedPaper;
  final ImageScalePreset selectedScale;
  final bool isBusy;
  final VoidCallback onOpenInteractivePdfModal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TwilightPalette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TwilightPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preview PO (${pages.length} Lembar)',
                style: TwilightTypography.serif(
                  size: 17,
                  weight: FontWeight.w600,
                ),
              ),
              if (pages.isNotEmpty)
                TextButton.icon(
                  onPressed: isBusy ? null : onOpenInteractivePdfModal,
                  style: TextButton.styleFrom(
                    foregroundColor: TwilightPalette.primary,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text('Lihat PDF'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (pages.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: TwilightPalette.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TwilightPalette.border),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.preview_outlined,
                    color: TwilightPalette.onSurfaceVariant,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada foto dipilih',
                    style: TwilightTypography.sans(
                      size: 13,
                      color: TwilightPalette.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                for (int pageIndex = 0;
                    pageIndex < pages.length;
                    pageIndex++) ...[
                  _buildPaperSheetPreview(
                    pageIndex: pageIndex,
                    totalPages: pages.length,
                    pageItems: pages[pageIndex],
                  ),
                  if (pageIndex < pages.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPaperSheetPreview({
    required int pageIndex,
    required int totalPages,
    required List<PoImageItem> pageItems,
  }) {
    final String dateStr = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lembar ${pageIndex + 1} / $totalPages',
                style: TwilightTypography.sans(
                  size: 12,
                  weight: FontWeight.w600,
                ),
              ),
              Text(
                '${selectedPaper.label} · ${pageItems.length} Foto',
                style: TwilightTypography.sans(
                  size: 11,
                  color: TwilightPalette.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AspectRatio(
          aspectRatio: selectedPaper.aspectRatio,
          child: LayoutBuilder(
            builder: (context, sheetConstraints) {
              final double marginPadding = sheetConstraints.maxWidth *
                  (selectedPaper.marginMm / selectedPaper.widthMm);
              return Container(
                padding: EdgeInsets.all(marginPadding),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: TwilightPalette.border, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 2),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF8C8881),
                            width: 0.7,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'PURCHASE ORDER (PO) · TOKO ${selectedStore.name.toUpperCase()}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF151413),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$dateStr · Hal. ${pageIndex + 1}/$totalPages',
                            style: const TextStyle(
                              fontSize: 7.5,
                              color: Color(0xFF4A4845),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < pageItems.length; i++) ...[
                            if (i > 0) const SizedBox(height: 4),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, slotConstraints) {
                                  final double maxSlotW =
                                      slotConstraints.maxWidth;
                                  final double maxSlotH =
                                      slotConstraints.maxHeight;
                                  final double targetW =
                                      maxSlotW * selectedScale.widthFactor;
                                  final double proportionalH =
                                      (targetW / pageItems[i].aspectRatio) *
                                          selectedScale.heightBoost;
                                  final double targetH =
                                      proportionalH <= maxSlotH
                                          ? proportionalH
                                          : maxSlotH;

                                  return Center(
                                    child: selectedScale.stretchToWidth
                                        ? SizedBox(
                                            width: targetW,
                                            height: targetH,
                                            child: Image.memory(
                                              pageItems[i].bytes,
                                              fit: BoxFit.fill,
                                            ),
                                          )
                                        : SizedBox(
                                            width: targetW,
                                            height: maxSlotH,
                                            child: Image.memory(
                                              pageItems[i].bytes,
                                              fit: BoxFit.contain,
                                            ),
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
