/// Controls how wide and tall the image is rendered across the paper sheet.
enum ImageScalePreset {
  fullMax(
    label: 'Selebar Kertas Penuh (Maksimal)',
    widthFactor: 1.0,
    heightBoost: 1.16,
    stretchToWidth: true,
  ),
  fullWidth(
    label: 'Selebar Kertas (Proporsional)',
    widthFactor: 1.0,
    heightBoost: 1.0,
    stretchToWidth: true,
  ),
  proportional(
    label: 'Standar (90% Lebar Kertas)',
    widthFactor: 0.90,
    heightBoost: 1.0,
    stretchToWidth: false,
  );

  const ImageScalePreset({
    required this.label,
    required this.widthFactor,
    required this.heightBoost,
    required this.stretchToWidth,
  });

  final String label;
  final double widthFactor;
  final double heightBoost;
  final bool stretchToWidth;
}
