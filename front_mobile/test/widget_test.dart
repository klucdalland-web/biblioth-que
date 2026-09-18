import 'package:flutter_test/flutter_test.dart';
import 'package:front_mobile/app/app.dart';
import 'package:front_mobile/core/network/api_client.dart';
import 'package:front_mobile/core/storage/token_storage.dart';
import 'package:front_mobile/data/repositories/auth_repository.dart';
import 'package:front_mobile/modules/auth/auth_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await GetStorage.init();
  });

  setUp(() {
    Get.reset();
    final storage = TokenStorage();
    Get.put<TokenStorage>(storage, permanent: true);
    Get.put<ApiClient>(ApiClient(storage), permanent: true);
    Get.put<AuthRepository>(AuthRepository(Get.find()), permanent: true);
    Get.put<AuthController>(
      AuthController(Get.find(), Get.find()),
      permanent: true,
    );
  });

  testWidgets('App démarre sur splash', (tester) async {
    await tester.pumpWidget(const BiblioApp());
    expect(find.text('BiblioGestion'), findsOneWidget);
  });
}
