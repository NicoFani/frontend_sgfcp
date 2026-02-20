import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiptStorageService {
  static String get bucket => dotenv.env['SUPABASE_BUCKET'] ?? 'receipts';

  static Future<String> uploadReceipt({
    required XFile file,
    required int driverId,
    int? tripId,
  }) async {
    final client = Supabase.instance.client;
    final bytes = await file.readAsBytes();

    final maxBytes = 5 * 1024 * 1024; // 5MB
    if (bytes.lengthInBytes > maxBytes) {
      throw Exception('El archivo supera el límite de 5MB');
    }

    final fileExt = _fileExtension(file.name);
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final tripSegment = tripId != null ? 'trip_$tripId' : 'sin_viaje';
    final filePath = 'driver_$driverId/$tripSegment/$timestamp.$fileExt';

    await client.storage
        .from(bucket)
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: _contentType(fileExt),
          ),
        );

    return '$bucket/$filePath';
  }

  static String _fileExtension(String name) {
    final parts = name.split('.');
    if (parts.length < 2) return 'jpg';
    return parts.last.toLowerCase();
  }

  static String _contentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }
}
