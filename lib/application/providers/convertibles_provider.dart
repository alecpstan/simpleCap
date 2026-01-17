import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'projection_adapters.dart';

part 'convertibles_provider.g.dart';

/// Watches all convertibles for the current company.
/// Uses event sourcing when active, falls back to direct DB otherwise.
@riverpod
Stream<List<Convertible>> convertiblesStream(ConvertiblesStreamRef ref) {
  return ref.watch(unifiedConvertiblesStreamProvider.stream);
}

/// Groups convertibles by status.
@riverpod
Map<String, List<Convertible>> convertiblesByStatus(
  ConvertiblesByStatusRef ref,
) {
  final convertiblesAsync = ref.watch(convertiblesStreamProvider);

  return convertiblesAsync.when(
    data: (convertibles) {
      final result = <String, List<Convertible>>{
        'outstanding': [],
        'converted': [],
        'cancelled': [],
      };

      for (final c in convertibles) {
        final status = c.status;
        if (result.containsKey(status)) {
          result[status]!.add(c);
        } else {
          result['outstanding']!.add(c);
        }
      }

      return result;
    },
    loading: () => {},
    error: (e, s) => {},
  );
}

/// Summary of convertibles for dashboard.
@riverpod
Future<ConvertiblesSummary> convertiblesSummary(
  ConvertiblesSummaryRef ref,
) async {
  final convertibles = await ref.watch(convertiblesStreamProvider.future);

  double outstandingPrincipal = 0;
  double convertedPrincipal = 0;
  int outstandingCount = 0;
  int safeCount = 0;
  int noteCount = 0;

  for (final c in convertibles) {
    if (c.status == 'outstanding') {
      outstandingPrincipal += c.principal;
      outstandingCount++;
    } else if (c.status == 'converted') {
      convertedPrincipal += c.principal;
    }

    if (c.type == 'safe') {
      safeCount++;
    } else {
      noteCount++;
    }
  }

  return ConvertiblesSummary(
    outstandingPrincipal: outstandingPrincipal,
    convertedPrincipal: convertedPrincipal,
    outstandingCount: outstandingCount,
    totalCount: convertibles.length,
    safeCount: safeCount,
    noteCount: noteCount,
  );
}

/// Summary data for convertibles.
class ConvertiblesSummary {
  final double outstandingPrincipal;
  final double convertedPrincipal;
  final int outstandingCount;
  final int totalCount;
  final int safeCount;
  final int noteCount;

  const ConvertiblesSummary({
    required this.outstandingPrincipal,
    required this.convertedPrincipal,
    required this.outstandingCount,
    required this.totalCount,
    required this.safeCount,
    required this.noteCount,
  });
}
