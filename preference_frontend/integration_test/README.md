# Integration Tests

This folder contains end-to-end (E2E) tests using `package:integration_test`.

How to run:
- On CI or locally without launching a device (Flutter >= 2.5 supports this):
  flutter test -d linux integration_test --reporter expanded

- Or using `flutter drive` (requires a connected/emulator device):
  flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_launch_e2e_test.dart

Notes:
- Tests avoid real network calls. The current app shows a static main screen, so no backend is contacted.
- If future network features are added, ensure they are mockable/disabled under test.
