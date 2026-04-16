import 'package:integration_test/integration_test.dart';

import 'tests/auth_test.dart' as auth;
import 'tests/user_flow_test.dart' as user;
import 'tests/admin_flow_test.dart' as admin;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  auth.main();
  user.main();
  admin.main();
}
