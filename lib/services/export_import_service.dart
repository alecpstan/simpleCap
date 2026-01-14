import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Result of an export or import operation
sealed class DataTransferResult {}

class DataTransferSuccess extends DataTransferResult {
  final String? fileName;
  final String? message;
  DataTransferSuccess({this.fileName, this.message});
}

class DataTransferCancelled extends DataTransferResult {}

class DataTransferError extends DataTransferResult {
  final String error;
  DataTransferError(this.error);
}

/// Service for exporting and importing cap table data
class ExportImportService {
  /// Export data to a JSON file using file picker
  /// Returns the result of the operation
  Future<DataTransferResult> exportData(Map<String, dynamic> data) async {
    try {
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final defaultFileName = 'simple_cap_backup_$timestamp.json';

      final jsonString = jsonEncode(data);
      final bytes = utf8.encode(jsonString);

      // Use file picker to save with bytes (required for iOS)
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(bytes),
      );

      if (result == null) {
        return DataTransferCancelled();
      }

      return DataTransferSuccess(fileName: result.split('/').last);
    } catch (e) {
      return DataTransferError(e.toString());
    }
  }

  /// Import data from a JSON file using file picker
  /// Returns the parsed data on success, or an error/cancelled result
  Future<DataTransferResult> pickFileForImport() async {
    try {
      // Use file picker to select file (with bytes for cross-platform support)
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Backup File',
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // Load file bytes directly
      );

      if (result == null || result.files.isEmpty) {
        return DataTransferCancelled();
      }

      final bytes = result.files.single.bytes;
      if (bytes == null) {
        return DataTransferError('Could not read file');
      }

      return DataTransferSuccess(
        fileName: result.files.single.name,
        message: utf8.decode(bytes),
      );
    } catch (e) {
      return DataTransferError(e.toString());
    }
  }

  /// Parse JSON content from file
  /// Returns null if parsing fails
  Map<String, dynamic>? parseImportContent(String jsonContent) {
    try {
      return jsonDecode(jsonContent) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
