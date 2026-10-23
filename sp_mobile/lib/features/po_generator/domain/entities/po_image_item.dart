import 'dart:typed_data';

/// Represents a user-selected image for the PO document.
class PoImageItem {
  const PoImageItem({
    required this.id,
    required this.name,
    required this.bytes,
    this.pixelWidth = 1200,
    this.pixelHeight = 900,
  });

  final String id;
  final String name;
  final Uint8List bytes;
  final int pixelWidth;
  final int pixelHeight;

  double get aspectRatio =>
      (pixelWidth > 0 && pixelHeight > 0) ? (pixelWidth / pixelHeight) : (4 / 3);
}
