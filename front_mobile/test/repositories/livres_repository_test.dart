import 'package:flutter_test/flutter_test.dart';
import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/data/datasources/local/livres_local_data_source.dart';
import 'package:front_mobile/data/datasources/remote/livres_remote_data_source.dart';
import 'package:front_mobile/data/models/livre_model.dart';
import 'package:front_mobile/data/repositories/livres_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements LivresRemoteDataSource {}

class _MockLocal extends Mock implements LivresLocalDataSource {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late LivresRepositoryImpl repo;

  final sample = PaginatedLivres(
    items: [
      LivreModel(
        id: 1,
        titre: 'Le Petit Prince',
        idAuteur: 2,
        statut: 'disponible',
      ),
    ],
    page: 1,
    totalPages: 1,
    total: 1,
  );

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    repo = LivresRepositoryImpl(remote, local);
  });

  group('LivresRepositoryImpl.list', () {
    test('succès remote → écrit le cache et fromCache=false', () async {
      when(
        () => remote.list(
          search: any(named: 'search'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => sample);
      when(
        () => local.saveList(
          sample,
          search: any(named: 'search'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async {});

      final result = await repo.list(page: 1, limit: 10);

      expect(result.fromCache, isFalse);
      expect(result.data.items, hasLength(1));
      expect(result.data.items.first.titre, 'Le Petit Prince');
      verify(
        () => local.saveList(
          sample,
          search: any(named: 'search'),
          page: 1,
          limit: 10,
        ),
      ).called(1);
    });

    test('échec réseau → fallback cache si disponible', () async {
      when(
        () => remote.list(
          search: any(named: 'search'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(
        ApiException('offline', type: ApiErrorType.noConnection),
      );
      when(
        () => local.readList(
          search: any(named: 'search'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenReturn(sample);

      final result = await repo.list(page: 1, limit: 10);

      expect(result.fromCache, isTrue);
      expect(result.data.total, 1);
    });

    test('échec réseau + cache vide → propage ApiException', () async {
      when(
        () => remote.list(
          search: any(named: 'search'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(
        ApiException('offline', type: ApiErrorType.noConnection),
      );
      when(
        () => local.readList(
          search: any(named: 'search'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenReturn(null);

      expect(
        () => repo.list(page: 1, limit: 10),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
