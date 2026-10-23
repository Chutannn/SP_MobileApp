/// Fixed store configurations requested by user:
/// 1. Satu Sama: 1-2 images per sheet (sized wide to approach paper width).
/// 2. Diamond: 1 image per sheet (sized wide to approach paper width).
enum StoreTarget {
  satuSama(
    id: 'satu_sama',
    name: 'Satu Sama',
    badgeLabel: '1-2 Gambar / Lembar',
    description:
        'Maksimal 2 gambar per halaman kertas (atas dan bawah), lebar foto mendekati lebar halaman.',
    maxImagesPerPage: 2,
  ),
  diamond(
    id: 'diamond',
    name: 'Diamond',
    badgeLabel: '1 Gambar / Lembar',
    description:
        'Khusus 1 gambar per halaman kertas, lebar foto diperbesar mendekati lebar halaman.',
    maxImagesPerPage: 1,
  );

  const StoreTarget({
    required this.id,
    required this.name,
    required this.badgeLabel,
    required this.description,
    required this.maxImagesPerPage,
  });

  final String id;
  final String name;
  final String badgeLabel;
  final String description;
  final int maxImagesPerPage;
}
