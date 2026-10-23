import 'package:flutter/material.dart';
import '../../../../core/theme/twilight_palette.dart';
import '../../../../core/theme/twilight_typography.dart';
import '../../domain/entities/image_scale_preset.dart';
import '../../domain/entities/paper_size_option.dart';
import '../../domain/entities/store_target.dart';

class PoStorePaperSection extends StatelessWidget {
  const PoStorePaperSection({
    super.key,
    required this.selectedStore,
    required this.selectedPaper,
    required this.selectedScale,
    required this.onSelectStore,
    required this.onSelectPaper,
    required this.onSelectScale,
  });

  final StoreTarget selectedStore;
  final PaperSizeOption selectedPaper;
  final ImageScalePreset selectedScale;
  final ValueChanged<StoreTarget> onSelectStore;
  final ValueChanged<PaperSizeOption> onSelectPaper;
  final ValueChanged<ImageScalePreset> onSelectScale;

  InputDecoration _formFieldDecoration(IconData leadingIcon) {
    return InputDecoration(
      filled: true,
      fillColor: TwilightPalette.background,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Icon(
          leadingIcon,
          size: 18,
          color: TwilightPalette.primary,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: TwilightPalette.border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: TwilightPalette.primary, width: 1.5),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TwilightTypography.sans(
          size: 12,
          weight: FontWeight.w500,
          color: TwilightPalette.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDropdownOptionRow({
    required String label,
    required bool isSelected,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? TwilightPalette.primary : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? TwilightPalette.primary
                  : TwilightPalette.onSurfaceVariant,
              width: 1.6,
            ),
          ),
          alignment: Alignment.center,
          child: isSelected
              ? const Icon(
                  Icons.check,
                  size: 10,
                  color: TwilightPalette.onPrimary,
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TwilightTypography.sans(
              size: 13.5,
              weight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? TwilightPalette.primary
                  : TwilightPalette.onSurface,
            ),
          ),
        ),
      ],
    );
  }

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
          Text(
            'Form Pengaturan PO',
            style: TwilightTypography.serif(
              size: 17,
              weight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _buildFieldLabel('Pilih Toko'),
          DropdownButtonFormField<StoreTarget>(
            key: ValueKey<StoreTarget>(selectedStore),
            initialValue: selectedStore,
            isExpanded: true,
            borderRadius: BorderRadius.circular(16),
            elevation: 8,
            dropdownColor: TwilightPalette.surface,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: TwilightPalette.primary,
            ),
            decoration: _formFieldDecoration(Icons.storefront_outlined),
            style: TwilightTypography.sans(
              size: 13.5,
              weight: FontWeight.w500,
            ),
            selectedItemBuilder: (context) {
              return StoreTarget.values.map((store) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${store.name} (${store.badgeLabel})',
                    overflow: TextOverflow.ellipsis,
                    style: TwilightTypography.sans(
                      size: 13.5,
                      weight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList();
            },
            items: StoreTarget.values.map((store) {
              final label = '${store.name} (${store.badgeLabel})';
              return DropdownMenuItem<StoreTarget>(
                value: store,
                child: _buildDropdownOptionRow(
                  label: label,
                  isSelected: store == selectedStore,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onSelectStore(value);
            },
          ),
          const SizedBox(height: 14),
          _buildFieldLabel('Ukuran Kertas'),
          DropdownButtonFormField<PaperSizeOption>(
            key: ValueKey<PaperSizeOption>(selectedPaper),
            initialValue: selectedPaper,
            isExpanded: true,
            borderRadius: BorderRadius.circular(16),
            elevation: 8,
            dropdownColor: TwilightPalette.surface,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: TwilightPalette.primary,
            ),
            decoration: _formFieldDecoration(Icons.description_outlined),
            style: TwilightTypography.sans(
              size: 13.5,
              weight: FontWeight.w500,
            ),
            selectedItemBuilder: (context) {
              return PaperSizeOption.values.map((paper) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${paper.label} (${paper.dimensionLabel})',
                    overflow: TextOverflow.ellipsis,
                    style: TwilightTypography.sans(
                      size: 13.5,
                      weight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList();
            },
            items: PaperSizeOption.values.map((paper) {
              final label = '${paper.label} (${paper.dimensionLabel})';
              return DropdownMenuItem<PaperSizeOption>(
                value: paper,
                child: _buildDropdownOptionRow(
                  label: label,
                  isSelected: paper == selectedPaper,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onSelectPaper(value);
            },
          ),
          const SizedBox(height: 14),
          _buildFieldLabel('Ukuran Foto di Kertas'),
          DropdownButtonFormField<ImageScalePreset>(
            key: ValueKey<ImageScalePreset>(selectedScale),
            initialValue: selectedScale,
            isExpanded: true,
            borderRadius: BorderRadius.circular(16),
            elevation: 8,
            dropdownColor: TwilightPalette.surface,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: TwilightPalette.primary,
            ),
            decoration: _formFieldDecoration(Icons.fit_screen_outlined),
            style: TwilightTypography.sans(
              size: 13.5,
              weight: FontWeight.w500,
            ),
            selectedItemBuilder: (context) {
              return ImageScalePreset.values.map((preset) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    preset.label,
                    overflow: TextOverflow.ellipsis,
                    style: TwilightTypography.sans(
                      size: 13.5,
                      weight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList();
            },
            items: ImageScalePreset.values.map((preset) {
              return DropdownMenuItem<ImageScalePreset>(
                value: preset,
                child: _buildDropdownOptionRow(
                  label: preset.label,
                  isSelected: preset == selectedScale,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onSelectScale(value);
            },
          ),
        ],
      ),
    );
  }
}
