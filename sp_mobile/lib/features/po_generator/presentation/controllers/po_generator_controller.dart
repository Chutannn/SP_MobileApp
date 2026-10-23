import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import '../../../../core/utils/pagination_utils.dart';
import '../../data/repositories/po_document_repository_impl.dart';
import '../../domain/entities/image_scale_preset.dart';
import '../../domain/entities/paper_size_option.dart';
import '../../domain/entities/po_image_item.dart';
import '../../domain/entities/store_target.dart';
import '../../domain/repositories/po_document_repository.dart';

/// Presentation controller managing PO generation state and user actions.
class PoGeneratorController extends ChangeNotifier {
  PoGeneratorController({
    PoDocumentRepository? repository,
    ImagePicker? picker,
  })  : _repository = repository ?? const PoDocumentRepositoryImpl(),
        _picker = picker ?? ImagePicker();

  final PoDocumentRepository _repository;
  final ImagePicker _picker;

  StoreTarget _selectedStore = StoreTarget.satuSama;
  PaperSizeOption _selectedPaper = PaperSizeOption.a4;
  ImageScalePreset _selectedScale = ImageScalePreset.fullMax;
  final List<PoImageItem> _images = [];

  bool _isBusy = false;
  String? _busyMessage;
  String? _errorMessage;
  String? _statusBanner;
  Uint8List? _cachedPdfBytes;

  StoreTarget get selectedStore => _selectedStore;
  PaperSizeOption get selectedPaper => _selectedPaper;
  ImageScalePreset get selectedScale => _selectedScale;
  List<PoImageItem> get images => List.unmodifiable(_images);
  bool get isBusy => _isBusy;
  String? get busyMessage => _busyMessage;
  String? get errorMessage => _errorMessage;
  String? get statusBanner => _statusBanner;

  List<List<PoImageItem>> get paginatedImages =>
      chunkImagesForPages(_images, _selectedStore.maxImagesPerPage);

  void _invalidatePdfCache() {
    _cachedPdfBytes = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearStatusBanner() {
    _statusBanner = null;
    notifyListeners();
  }

  void selectStore(StoreTarget store) {
    if (_selectedStore == store) return;
    _selectedStore = store;
    _invalidatePdfCache();
    notifyListeners();
  }

  void selectPaper(PaperSizeOption paper) {
    if (_selectedPaper == paper) return;
    _selectedPaper = paper;
    _invalidatePdfCache();
    notifyListeners();
  }

  void selectScale(ImageScalePreset preset) {
    if (_selectedScale == preset) return;
    _selectedScale = preset;
    _invalidatePdfCache();
    notifyListeners();
  }

  String buildFileName() {
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'PO_${_selectedStore.id}_${_selectedPaper.label}_$stamp.pdf';
  }

  Future<Uint8List> getOrBuildPdfBytes() async {
    if (_cachedPdfBytes != null) return _cachedPdfBytes!;
    final bytes = await _repository.buildPdfBytes(
      store: _selectedStore,
      paperSize: _selectedPaper,
      images: _images,
      createdAt: DateTime.now(),
      scalePreset: _selectedScale,
    );
    _cachedPdfBytes = bytes;
    return bytes;
  }

  Future<Uint8List> buildPdfBytesForPrinterFormat(PdfPageFormat format) {
    final targetFormat = _repository.resolvePrintPageFormat(
      printerFormat: format,
      paperSize: _selectedPaper,
    );
    return _repository.buildPdfBytes(
      store: _selectedStore,
      paperSize: _selectedPaper,
      images: _images,
      createdAt: DateTime.now(),
      scalePreset: _selectedScale,
      pageFormatOverride: targetFormat,
    );
  }

  Future<void> pickImagesFromGallery() async {
    _isBusy = true;
    _busyMessage = 'Memuat gambar...';
    _errorMessage = null;
    _statusBanner = null;
    notifyListeners();

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 92,
      );
      if (pickedFiles.isEmpty) {
        _isBusy = false;
        _busyMessage = null;
        notifyListeners();
        return;
      }

      final List<PoImageItem> loaded = [];
      for (final file in pickedFiles) {
        final rawBytes = await file.readAsBytes();
        final normalized = await _repository.normalizeImage(rawBytes);
        loaded.add(
          PoImageItem(
            id: '${DateTime.now().microsecondsSinceEpoch}_${loaded.length}',
            name: file.name,
            bytes: normalized.bytes,
            pixelWidth: normalized.width,
            pixelHeight: normalized.height,
          ),
        );
      }

      _images.addAll(loaded);
      _invalidatePdfCache();
      _isBusy = false;
      _busyMessage = null;
      _statusBanner = '${loaded.length} foto ditambahkan.';
      notifyListeners();
    } catch (_) {
      _isBusy = false;
      _busyMessage = null;
      _errorMessage = 'Gagal mengambil gambar dari galeri.';
      notifyListeners();
    }
  }

  Future<void> pickImageFromCamera() async {
    _isBusy = true;
    _busyMessage = 'Membuka kamera...';
    _errorMessage = null;
    _statusBanner = null;
    notifyListeners();

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 92,
      );
      if (photo == null) {
        _isBusy = false;
        _busyMessage = null;
        notifyListeners();
        return;
      }

      final rawBytes = await photo.readAsBytes();
      final normalized = await _repository.normalizeImage(rawBytes);
      _images.add(
        PoImageItem(
          id: '${DateTime.now().microsecondsSinceEpoch}',
          name: photo.name,
          bytes: normalized.bytes,
          pixelWidth: normalized.width,
          pixelHeight: normalized.height,
        ),
      );
      _invalidatePdfCache();
      _isBusy = false;
      _busyMessage = null;
      _statusBanner = 'Foto kamera ditambahkan.';
      notifyListeners();
    } catch (_) {
      _isBusy = false;
      _busyMessage = null;
      _errorMessage = 'Kamera tidak tersedia pada perangkat ini.';
      notifyListeners();
    }
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= _images.length) return;
    _images.removeAt(index);
    _invalidatePdfCache();
    notifyListeners();
  }

  void moveImage(int oldIndex, int newIndex) {
    if (newIndex < 0 || newIndex >= _images.length) return;
    final item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);
    _invalidatePdfCache();
    notifyListeners();
  }

  void clearAllImages() {
    _images.clear();
    _invalidatePdfCache();
    _statusBanner = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> printPo() async {
    if (_images.isEmpty) {
      _errorMessage = 'Pilih minimal 1 foto sebelum mencetak PO.';
      notifyListeners();
      return;
    }

    _isBusy = true;
    _busyMessage = 'Menghubungkan ke printer...';
    _errorMessage = null;
    _statusBanner = null;
    notifyListeners();

    try {
      await _repository.printPoDocument(
        fileName: buildFileName(),
        store: _selectedStore,
        paperSize: _selectedPaper,
        images: _images,
        scalePreset: _selectedScale,
      );
      _isBusy = false;
      _busyMessage = null;
      notifyListeners();
    } catch (_) {
      _isBusy = false;
      _busyMessage = null;
      _errorMessage = 'Gagal membuka layanan printer.';
      notifyListeners();
    }
  }

  /// Downloads the generated PO PDF to the user's Download folder and returns
  /// the user-facing status message if successful.
  Future<String?> downloadPo() async {
    if (_images.isEmpty) {
      _errorMessage = 'Pilih minimal 1 foto sebelum mengunduh PO.';
      notifyListeners();
      return null;
    }

    _isBusy = true;
    _busyMessage = 'Menyimpan PDF ke folder Download...';
    _errorMessage = null;
    _statusBanner = null;
    notifyListeners();

    try {
      final pdfBytes = await getOrBuildPdfBytes();
      final fileName = buildFileName();
      final savedFilePath = await _repository.savePoPdfToDownloads(
        fileName: fileName,
        pdfBytes: pdfBytes,
      );
      final String message = savedFilePath != null
          ? 'Tersimpan: $savedFilePath'
          : 'File PO ($fileName) siap disimpan.';
      _isBusy = false;
      _busyMessage = null;
      _statusBanner = message;
      notifyListeners();
      return message;
    } catch (_) {
      _isBusy = false;
      _busyMessage = null;
      _errorMessage = 'Gagal menyimpan file PDF.';
      notifyListeners();
      return null;
    }
  }
}
