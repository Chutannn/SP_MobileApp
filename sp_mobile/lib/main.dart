import 'package:flutter/material.dart';
import 'app.dart';

export 'app.dart';
export 'core/theme/twilight_palette.dart';
export 'core/theme/twilight_typography.dart';
export 'core/utils/pagination_utils.dart';
export 'features/home/presentation/pages/home_screen.dart';
export 'features/po_generator/data/datasources/file_download_datasource.dart';
export 'features/po_generator/data/datasources/image_processing_datasource.dart';
export 'features/po_generator/data/datasources/pdf_builder_datasource.dart';
export 'features/po_generator/data/repositories/po_document_repository_impl.dart';
export 'features/po_generator/domain/entities/image_scale_preset.dart';
export 'features/po_generator/domain/entities/paper_size_option.dart';
export 'features/po_generator/domain/entities/po_image_item.dart';
export 'features/po_generator/domain/entities/store_target.dart';
export 'features/po_generator/domain/repositories/po_document_repository.dart';
export 'features/po_generator/presentation/controllers/po_generator_controller.dart';
export 'features/po_generator/presentation/pages/po_generator_screen.dart';
export 'features/shell/presentation/pages/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SariPurnamaApp());
}
