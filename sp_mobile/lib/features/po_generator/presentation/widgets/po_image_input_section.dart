import 'package:flutter/material.dart';
import '../../../../core/theme/twilight_palette.dart';
import '../../../../core/theme/twilight_typography.dart';
import '../../domain/entities/po_image_item.dart';
import '../../domain/entities/store_target.dart';

class PoImageInputSection extends StatelessWidget {
  const PoImageInputSection({
    super.key,
    required this.images,
    required this.selectedStore,
    required this.isBusy,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onClearAll,
    required this.onMoveImage,
    required this.onRemoveImageAt,
  });

  final List<PoImageItem> images;
  final StoreTarget selectedStore;
  final bool isBusy;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onClearAll;
  final void Function(int oldIndex, int newIndex) onMoveImage;
  final ValueChanged<int> onRemoveImageAt;

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
                'Foto Nota (${images.length})',
                style: TwilightTypography.serif(
                  size: 17,
                  weight: FontWeight.w600,
                ),
              ),
              if (images.isNotEmpty)
                TextButton.icon(
                  onPressed: isBusy ? null : onClearAll,
                  style: TextButton.styleFrom(
                    foregroundColor: TwilightPalette.destructiveText,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.delete_sweep_outlined, size: 17),
                  label: const Text('Reset'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: isBusy ? null : onPickGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TwilightPalette.primary,
                      foregroundColor: TwilightPalette.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      size: 18,
                    ),
                    label: Text(
                      'Pilih Gambar',
                      style: TwilightTypography.sans(
                        size: 13,
                        weight: FontWeight.w600,
                        color: TwilightPalette.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : onPickCamera,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TwilightPalette.onSurface,
                      side: const BorderSide(color: TwilightPalette.border),
                      backgroundColor: TwilightPalette.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: Text(
                      'Kamera',
                      style: TwilightTypography.sans(
                        size: 13,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (int i = 0; i < images.length; i++) ...[
              _buildUploadedImageRow(index: i, item: images[i]),
              if (i < images.length - 1) const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildUploadedImageRow({
    required int index,
    required PoImageItem item,
  }) {
    final int pageNum = (index ~/ selectedStore.maxImagesPerPage) + 1;
    final int slotInPage = (index % selectedStore.maxImagesPerPage) + 1;
    final String positionInfo = selectedStore.maxImagesPerPage == 1
        ? 'Hal. $pageNum'
        : 'Hal. $pageNum (${slotInPage == 1 ? "Atas" : "Bawah"})';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: TwilightPalette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TwilightPalette.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              item.bytes,
              width: 42,
              height: 42,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Foto #${index + 1}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TwilightTypography.sans(
                    size: 13,
                    weight: FontWeight.w600,
                  ),
                ),
                Text(
                  positionInfo,
                  style: TwilightTypography.sans(
                    size: 11,
                    color: TwilightPalette.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Geser Naik',
            visualDensity: VisualDensity.compact,
            onPressed: index > 0 ? () => onMoveImage(index, index - 1) : null,
            icon: const Icon(Icons.keyboard_arrow_up, size: 20),
          ),
          IconButton(
            tooltip: 'Geser Turun',
            visualDensity: VisualDensity.compact,
            onPressed: index < images.length - 1
                ? () => onMoveImage(index, index + 1)
                : null,
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          ),
          IconButton(
            tooltip: 'Hapus',
            visualDensity: VisualDensity.compact,
            onPressed: () => onRemoveImageAt(index),
            icon: const Icon(
              Icons.delete_outline,
              size: 19,
              color: TwilightPalette.destructiveText,
            ),
          ),
        ],
      ),
    );
  }
}
