import 'package:flutter/material.dart';
import '../../../../core/theme/twilight_palette.dart';
import '../../../../core/theme/twilight_typography.dart';
import '../../../po_generator/presentation/controllers/po_generator_controller.dart';
import '../../../po_generator/presentation/widgets/po_top_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.poController,
    required this.onOpenPoPage,
  });

  final PoGeneratorController poController;
  final VoidCallback onOpenPoPage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PoTopBar(
          title: 'Sari Purnama',
          subtitle: 'Pembukuan & Operasional',
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            children: [
              Text(
                'Menu Utama',
                style: TwilightTypography.serif(
                  size: 17,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.print_outlined,
                title: 'Buat File PO',
                subtitle: 'Susun foto nota, download PDF, dan print PO',
                onTap: onOpenPoPage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TwilightPalette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TwilightPalette.border, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: TwilightPalette.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TwilightPalette.border),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: TwilightPalette.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TwilightTypography.sans(
                      size: 15,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TwilightTypography.sans(
                      size: 12,
                      color: TwilightPalette.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: TwilightPalette.primary,
            ),
          ],
        ),
      ),
    );
  }
}
