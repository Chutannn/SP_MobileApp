import 'package:flutter/material.dart';
import '../../../../core/theme/twilight_palette.dart';
import '../../../../core/theme/twilight_typography.dart';
import '../../domain/entities/paper_size_option.dart';

class PoBottomActionBar extends StatelessWidget {
  const PoBottomActionBar({
    super.key,
    required this.hasImages,
    required this.isBusy,
    required this.selectedPaper,
    required this.onDownloadPo,
    required this.onPrintPo,
  });

  final bool hasImages;
  final bool isBusy;
  final PaperSizeOption selectedPaper;
  final VoidCallback onDownloadPo;
  final VoidCallback onPrintPo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: (!hasImages || isBusy) ? null : onDownloadPo,
              style: OutlinedButton.styleFrom(
                foregroundColor: TwilightPalette.onSurface,
                disabledForegroundColor:
                    TwilightPalette.onSurfaceVariant.withValues(alpha: 0.45),
                backgroundColor: TwilightPalette.surface,
                side: BorderSide(
                  color: hasImages
                      ? TwilightPalette.onSurfaceVariant
                      : TwilightPalette.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.download_outlined, size: 19),
              label: Text(
                'Download',
                style: TwilightTypography.sans(
                  size: 13,
                  weight: FontWeight.w600,
                  color: hasImages
                      ? TwilightPalette.onSurface
                      : TwilightPalette.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: (!hasImages || isBusy) ? null : onPrintPo,
              style: ElevatedButton.styleFrom(
                backgroundColor: TwilightPalette.primary,
                foregroundColor: TwilightPalette.onPrimary,
                disabledBackgroundColor: TwilightPalette.surfaceAlt,
                disabledForegroundColor: TwilightPalette.onSurfaceVariant,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.print_rounded, size: 19),
              label: Text(
                'Print (${selectedPaper.label})',
                style: TwilightTypography.sans(
                  size: 13,
                  weight: FontWeight.w700,
                  color: hasImages
                      ? TwilightPalette.onPrimary
                      : TwilightPalette.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
