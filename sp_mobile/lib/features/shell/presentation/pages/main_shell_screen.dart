import 'package:flutter/material.dart';
import '../../../../core/theme/twilight_palette.dart';
import '../../../../core/theme/twilight_typography.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../../po_generator/presentation/controllers/po_generator_controller.dart';
import '../../../po_generator/presentation/pages/po_generator_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late final PoGeneratorController _poController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _poController = PoGeneratorController();
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _poController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget activePage = _currentIndex == 0
        ? HomeScreen(
            key: const ValueKey<int>(0),
            poController: _poController,
            onOpenPoPage: () => _switchTab(1),
          )
        : PoGeneratorScreen(
            key: const ValueKey<int>(1),
            controller: _poController,
          );

    return Scaffold(
      backgroundColor: TwilightPalette.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.03, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: activePage,
                  ),
                ),
                _buildFloatingBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 6, 28, 14),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: TwilightPalette.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: TwilightPalette.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.38),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildFloatingNavItem(
                index: 0,
                label: 'Beranda',
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildFloatingNavItem(
                index: 1,
                label: 'Buat PO',
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData selectedIcon,
  }) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _switchTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? TwilightPalette.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 19,
              color: isSelected
                  ? TwilightPalette.onPrimary
                  : TwilightPalette.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TwilightTypography.sans(
                size: 13,
                weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? TwilightPalette.onPrimary
                    : TwilightPalette.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
