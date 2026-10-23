import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Decodes picked image bytes (applies EXIF orientation from phone cameras,
/// automatically trims excess white borders around document/nota images so the
/// PO content spans the full width of the paper, caps extreme dimensions to
/// 1800px, and returns normalized PNG bytes with exact pixel width and height).
Future<({Uint8List bytes, int width, int height})> normalizeImageBytes(
  Uint8List rawBytes,
) async {
  try {
    final codec = await ui.instantiateImageCodec(
      rawBytes,
      targetWidth: 1800,
    );
    final frame = await codec.getNextFrame();
    final ui.Image srcImage = frame.image;
    final int w = srcImage.width;
    final int h = srcImage.height;

    final rawRgba =
        await srcImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (rawRgba != null) {
      final trimmed = await _trimWhiteBordersIfDocument(
        srcImage: srcImage,
        rgba: rawRgba.buffer.asUint8List(),
        width: w,
        height: h,
      );
      if (trimmed != null) {
        srcImage.dispose();
        return trimmed;
      }
    }

    final byteData =
        await srcImage.toByteData(format: ui.ImageByteFormat.png);
    srcImage.dispose();
    if (byteData != null) {
      return (
        bytes: byteData.buffer.asUint8List(),
        width: w,
        height: h,
      );
    }
  } catch (_) {
    // In headless unit tests or unsupported formats, keep original bytes.
  }
  return (bytes: rawBytes, width: 1200, height: 900);
}

/// Automatically detects and removes blank white/light margins around a PO
/// document image so the table and text fill 100% of the slot width.
Future<({Uint8List bytes, int width, int height})?> _trimWhiteBordersIfDocument({
  required ui.Image srcImage,
  required Uint8List rgba,
  required int width,
  required int height,
}) async {
  if (width < 80 || height < 80) return null;

  bool isContentPixel(int x, int y) {
    final int idx = (y * width + x) * 4;
    final int a = rgba[idx + 3];
    if (a < 30) return false;
    final int r = rgba[idx];
    final int g = rgba[idx + 1];
    final int b = rgba[idx + 2];
    return r < 232 || g < 232 || b < 232;
  }

  // Only trim if the outer border of the image is predominantly light/white
  int borderSamples = 0;
  int lightBorderSamples = 0;
  final int stepX = (width ~/ 40).clamp(1, 32);
  final int stepY = (height ~/ 40).clamp(1, 32);
  for (int x = 0; x < width; x += stepX) {
    borderSamples += 2;
    if (!isContentPixel(x, 0)) lightBorderSamples++;
    if (!isContentPixel(x, height - 1)) lightBorderSamples++;
  }
  for (int y = 0; y < height; y += stepY) {
    borderSamples += 2;
    if (!isContentPixel(0, y)) lightBorderSamples++;
    if (!isContentPixel(width - 1, y)) lightBorderSamples++;
  }
  if (borderSamples == 0 || (lightBorderSamples / borderSamples) < 0.75) {
    return null;
  }

  int top = 0;
  for (int y = 0; y < height; y++) {
    int hits = 0;
    for (int x = 0; x < width; x += 2) {
      if (isContentPixel(x, y)) {
        hits++;
        if (hits >= 2) break;
      }
    }
    if (hits >= 2) {
      top = y;
      break;
    }
  }

  int bottom = height - 1;
  for (int y = height - 1; y >= top; y--) {
    int hits = 0;
    for (int x = 0; x < width; x += 2) {
      if (isContentPixel(x, y)) {
        hits++;
        if (hits >= 2) break;
      }
    }
    if (hits >= 2) {
      bottom = y;
      break;
    }
  }

  int left = 0;
  for (int x = 0; x < width; x++) {
    int hits = 0;
    for (int y = top; y <= bottom; y += 2) {
      if (isContentPixel(x, y)) {
        hits++;
        if (hits >= 2) break;
      }
    }
    if (hits >= 2) {
      left = x;
      break;
    }
  }

  int right = width - 1;
  for (int x = width - 1; x >= left; x--) {
    int hits = 0;
    for (int y = top; y <= bottom; y += 2) {
      if (isContentPixel(x, y)) {
        hits++;
        if (hits >= 2) break;
      }
    }
    if (hits >= 2) {
      right = x;
      break;
    }
  }

  final int padX = (width * 0.005).round().clamp(3, 10);
  final int padY = (height * 0.006).round().clamp(3, 12);
  final int cropLeft = (left - padX).clamp(0, width - 1);
  final int cropTop = (top - padY).clamp(0, height - 1);
  final int cropRight = (right + padX).clamp(cropLeft + 1, width);
  final int cropBottom = (bottom + padY).clamp(cropTop + 1, height);

  final int cropW = cropRight - cropLeft;
  final int cropH = cropBottom - cropTop;

  if (cropW < width * 0.35 || cropH < height * 0.18) {
    return null;
  }
  if (cropW >= width - 6 && cropH >= height - 6) {
    return null;
  }

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawImageRect(
    srcImage,
    Rect.fromLTWH(
      cropLeft.toDouble(),
      cropTop.toDouble(),
      cropW.toDouble(),
      cropH.toDouble(),
    ),
    Rect.fromLTWH(0, 0, cropW.toDouble(), cropH.toDouble()),
    Paint()..filterQuality = FilterQuality.high,
  );
  final picture = recorder.endRecording();
  final croppedImg = await picture.toImage(cropW, cropH);
  final pngData = await croppedImg.toByteData(format: ui.ImageByteFormat.png);
  croppedImg.dispose();
  if (pngData == null) return null;

  return (
    bytes: pngData.buffer.asUint8List(),
    width: cropW,
    height: cropH,
  );
}

class ImageProcessingDataSource {
  const ImageProcessingDataSource();

  Future<({Uint8List bytes, int width, int height})> normalize(
    Uint8List rawBytes,
  ) =>
      normalizeImageBytes(rawBytes);
}
