import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';

part 'database_provider.g.dart';

/// Provides a singleton instance of the app database.
///
/// This is the only place where [AppDatabase] is instantiated.
/// All other providers should depend on this.
@Riverpod(keepAlive: true)
AppDatabase database(DatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}
