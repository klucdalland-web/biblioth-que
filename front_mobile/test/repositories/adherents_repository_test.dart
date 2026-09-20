import 'package:flutter_test/flutter_test.dart';
import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/data/datasources/local/adherents_local_data_source.dart';
import 'package:front_mobile/data/datasources/remote/adherents_remote_data_source.dart';
import 'package:front_mobile/data/models/adherent_model.dart';
import 'package:front_mobile/data/repositories/adherents_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements AdherentsRemoteDataSource {}

class _MockLocal extends Mock implements AdherentsLocalDataSource {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late AdherentsRepositoryImpl repo;

  final sample = [
    AdherentModel(id: 1, nom: 'Dupont', contact: 'dupont@mail.com'),
  ];

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    repo = AdherentsRepositoryImpl(remote, local);
  });

  group('AdherentsRepositoryImpl.list', () {
    test('succès remote → écrit le cache', () async {
      when(() => remote.list(search: any(named: 'search')))
          .thenAnswer((_) async => sample);
      when(
        () => local.saveList(sample, search: any(named: 'search')),
      ).thenAnswer((_) async {});

      final result = await repo.list();

      expect(result.fromCache, isFalse);
      expect(result.data.first.nom, 'Dupont');
      verify(() => local.saveList(sample, search: any(named: 'search')))
          .called(1);
    });

    test('échec réseau → retourne le cache', () async {
      when(() => remote.list(search: any(named: 'search'))).thenThrow(
        ApiException('timeout', type: ApiErrorType.timeout),
      );
      when(() => local.readList(search: any(named: 'search')))
          .thenReturn(sample);

      final result = await repo.list();

      expect(result.fromCache, isTrue);
      expect(result.data, hasLength(1));
    });

    test('échec réseau sans cache → ApiException', () async {
      when(() => remote.list(search: any(named: 'search'))).thenThrow(
        ApiException('timeout', type: ApiErrorType.timeout),
      );
      when(() => local.readList(search: any(named: 'search'))).thenReturn(null);

      expect(() => repo.list(), throwsA(isA<ApiException>()));
    });
  });
}
