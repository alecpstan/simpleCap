import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../infrastructure/database/database.dart';
import 'database_provider.dart';
import 'company_provider.dart';
import 'mfn_provider.dart';

part 'convertibles_provider.g.dart';

/// Watches all convertibles for the current company.
@riverpod
Stream<List<Convertible>> convertiblesStream(ConvertiblesStreamRef ref) {
  final companyId = ref.watch(currentCompanyIdProvider);
  if (companyId == null) return Stream.value([]);

  final db = ref.watch(databaseProvider);
  return db.watchConvertibles(companyId);
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

/// Notifier for convertible mutations.
@riverpod
class ConvertibleMutations extends _$ConvertibleMutations {
  @override
  FutureOr<void> build() {}

  Future<String> create({
    required String companyId,
    required String stakeholderId,
    required String type, // 'safe' or 'note'
    required double principal,
    required DateTime issueDate,
    String status = 'outstanding', // 'pending' when created in round builder
    String? roundId, // Round issued in (for pending instruments)
    double? valuationCap,
    double? discountPercent,
    double? interestRate,
    DateTime? maturityDate,
    bool hasMfn = false,
    bool hasProRata = false,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    await db.upsertConvertible(
      ConvertiblesCompanion.insert(
        id: id,
        companyId: companyId,
        stakeholderId: stakeholderId,
        type: type,
        status: Value(status),
        principal: principal,
        issueDate: issueDate,
        roundId: Value(roundId),
        valuationCap: Value(valuationCap),
        discountPercent: Value(discountPercent),
        interestRate: Value(interestRate),
        maturityDate: Value(maturityDate),
        hasMfn: Value(hasMfn),
        hasProRata: Value(hasProRata),
        notes: Value(notes),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return id;
  }

  Future<void> updateConvertible({
    required String id,
    String? stakeholderId,
    String? type,
    String? status,
    String? roundId,
    double? principal,
    double? valuationCap,
    double? discountPercent,
    double? interestRate,
    DateTime? issueDate,
    DateTime? maturityDate,
    bool? hasMfn,
    bool? hasProRata,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    final existing = await db.getConvertible(id);
    if (existing == null) throw Exception('Convertible not found');

    await db.upsertConvertible(
      ConvertiblesCompanion(
        id: Value(id),
        companyId: Value(existing.companyId),
        stakeholderId: Value(stakeholderId ?? existing.stakeholderId),
        type: Value(type ?? existing.type),
        status: Value(status ?? existing.status),
        roundId: Value(roundId ?? existing.roundId),
        principal: Value(principal ?? existing.principal),
        valuationCap: Value(valuationCap ?? existing.valuationCap),
        discountPercent: Value(discountPercent ?? existing.discountPercent),
        interestRate: Value(interestRate ?? existing.interestRate),
        issueDate: Value(issueDate ?? existing.issueDate),
        maturityDate: Value(maturityDate ?? existing.maturityDate),
        hasMfn: Value(hasMfn ?? existing.hasMfn),
        hasProRata: Value(hasProRata ?? existing.hasProRata),
        notes: Value(notes ?? existing.notes),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Check if this edit should revert any MFN upgrades this convertible triggered
    // (e.g., if discount or cap were changed to less favorable terms)
    if (discountPercent != null || valuationCap != null || hasProRata != null) {
      await ref.read(mfnMutationsProvider.notifier).checkAndRevertIfNeeded(id);
    }
  }

  Future<void> convert({
    required String id,
    required String shareClassId,
    required int sharesReceived,
    String? conversionEventId,
  }) async {
    final db = ref.read(databaseProvider);
    final existing = await db.getConvertible(id);
    if (existing == null) throw Exception('Convertible not found');

    await db.upsertConvertible(
      ConvertiblesCompanion(
        id: Value(id),
        companyId: Value(existing.companyId),
        stakeholderId: Value(existing.stakeholderId),
        type: Value(existing.type),
        status: const Value('converted'),
        principal: Value(existing.principal),
        valuationCap: Value(existing.valuationCap),
        discountPercent: Value(existing.discountPercent),
        interestRate: Value(existing.interestRate),
        issueDate: Value(existing.issueDate),
        maturityDate: Value(existing.maturityDate),
        hasMfn: Value(existing.hasMfn),
        hasProRata: Value(existing.hasProRata),
        conversionEventId: Value(conversionEventId),
        convertedToShareClassId: Value(shareClassId),
        sharesReceived: Value(sharesReceived),
        notes: Value(existing.notes),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteConvertible(id);
  }
}
