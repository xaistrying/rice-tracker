// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:rice_tracker/data/datasources/purchaser_data_source.dart';
import 'package:rice_tracker/data/repositories/purchaser_repository_impl.dart';
import 'package:rice_tracker/domain/models/purchaser_model.dart';
import 'package:rice_tracker/domain/models/stored_purchaser_list.dart';

/// A data source that answers however a test needs it to.
///
/// Standing this up takes no container and no SharedPreferences: the point of
/// the constructor injection is that the layer below can simply be replaced.
class FakePurchaserDataSource implements PurchaserDataSource {
  FakePurchaserDataSource({this.onRead, this.onWrite, this.onBackup});

  final StoredPurchaserList Function()? onRead;
  final void Function(List<PurchaserModel>)? onWrite;
  final bool Function()? onBackup;

  List<PurchaserModel>? lastWritten;

  @override
  StoredPurchaserList getPurchaserList() =>
      onRead?.call() ?? const StoredPurchaserList();

  @override
  Future<void> cachePurchaserList({
    required List<PurchaserModel> purchaserList,
  }) async {
    lastWritten = purchaserList;
    onWrite?.call(purchaserList);
  }

  @override
  Future<bool> backupPurchaserList() async => onBackup?.call() ?? false;
}

void main() {
  test('a read is passed straight through', () {
    final repo = PurchaserRepositoryImpl(
      FakePurchaserDataSource(
        onRead: () => StoredPurchaserList(
          purchasers: [PurchaserModel(id: '1', name: 'Alice')],
        ),
      ),
    );

    final result = repo.getPurchaserList();

    expect(result.isRight(), isTrue);
    expect(
      result
          .getOrElse((_) => const StoredPurchaserList())
          .purchasers
          .single
          .name,
      'Alice',
    );
  });

  test('a partial read keeps its skipped count', () {
    final repo = PurchaserRepositoryImpl(
      FakePurchaserDataSource(
        onRead: () => const StoredPurchaserList(skipped: 2),
      ),
    );

    final stored = repo.getPurchaserList().getOrElse(
      (_) => const StoredPurchaserList(),
    );

    expect(stored.isComplete, isFalse);
    expect(stored.skipped, 2);
  });

  test('a throwing read becomes a Left, not an empty list', () {
    final repo = PurchaserRepositoryImpl(
      FakePurchaserDataSource(
        onRead: () => throw const FormatException('unreadable'),
      ),
    );

    final result = repo.getPurchaserList();

    expect(result.isLeft(), isTrue);
    result.match(
      (failure) => expect(failure.cause, isA<FormatException>()),
      (_) => fail('expected a Left'),
    );
  });

  test('a failed write becomes a Left carrying its cause', () async {
    final repo = PurchaserRepositoryImpl(
      FakePurchaserDataSource(onWrite: (_) => throw Exception('disk full')),
    );

    final result = await repo.cachePurchaserList(purchaserList: []);

    expect(result.isLeft(), isTrue);
    result.match(
      // The cause used to be flattened to a string and then discarded.
      (failure) => expect(failure.cause, isNotNull),
      (_) => fail('expected a Left'),
    );
  });

  test('a successful write reaches the data source', () async {
    final dataSource = FakePurchaserDataSource();
    final repo = PurchaserRepositoryImpl(dataSource);

    final result = await repo.cachePurchaserList(
      purchaserList: [PurchaserModel(id: '1', name: 'Alice')],
    );

    expect(result.isRight(), isTrue);
    expect(dataSource.lastWritten!.single.name, 'Alice');
  });
}
