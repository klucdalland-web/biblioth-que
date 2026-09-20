import 'package:flutter_test/flutter_test.dart';
import 'package:front_mobile/core/network/api_exception.dart';
import 'package:front_mobile/data/datasources/remote/auth_remote_data_source.dart';
import 'package:front_mobile/data/models/auth_tokens_model.dart';
import 'package:front_mobile/data/models/user_model.dart';
import 'package:front_mobile/data/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late AuthRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    repo = AuthRepositoryImpl(remote);
  });

  group('AuthRepositoryImpl', () {
    test('login délègue et retourne les tokens', () async {
      final tokens = AuthTokensModel(
        accessToken: 'access',
        refreshToken: 'refresh',
        user: UserModel(
          id: 1,
          nom: 'Admin',
          email: 'a@b.c',
          role: 'admin',
        ),
      );
      when(
        () => remote.login(mail: any(named: 'mail'), password: any(named: 'password')),
      ).thenAnswer((_) async => tokens);

      final result = await repo.login(mail: 'a@b.c', password: 'secret');

      expect(result.accessToken, 'access');
      expect(result.refreshToken, 'refresh');
      expect(result.user?.isAdmin, isTrue);
      verify(
        () => remote.login(mail: 'a@b.c', password: 'secret'),
      ).called(1);
    });

    test('me retourne le profil utilisateur', () async {
      final user = UserModel(
        id: 2,
        nom: 'Bib',
        email: 'bib@mail.com',
        role: 'bibliothecaire',
      );
      when(() => remote.me()).thenAnswer((_) async => user);

      final result = await repo.me();

      expect(result.email, 'bib@mail.com');
      expect(result.isAdmin, isFalse);
    });

    test('login propage ApiException depuis le remote', () async {
      when(
        () => remote.login(mail: any(named: 'mail'), password: any(named: 'password')),
      ).thenThrow(
        ApiException('Identifiants invalides', type: ApiErrorType.unauthorized),
      );

      expect(
        () => repo.login(mail: 'x', password: 'y'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Identifiants invalides',
          ),
        ),
      );
    });
  });
}
