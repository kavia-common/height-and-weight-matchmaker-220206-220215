# preference_frontend

A new Flutter project.

## Continuous Integration (GitHub Actions)

This repository includes a CI workflow at `.github/workflows/flutter_ci.yaml` that runs on every push and pull request.

Jobs:
- Analyze, Unit and Widget Tests (ubuntu-latest)
  - Checks out code
  - Sets up Flutter (stable channel)
  - Caches pub dependencies and build artifacts
  - Runs `flutter pub get`
  - Runs `flutter analyze`
  - Runs unit and widget tests with expanded reporter: `flutter test --reporter=expanded -v`
  - Saves test logs as workflow artifacts

- Linux Desktop Integration Tests (Xvfb)
  - Installs Linux desktop dependencies (GTK, cmake, ninja, etc.)
  - Enables Linux desktop: `flutter config --enable-linux-desktop`
  - Starts Xvfb and runs tests headlessly with `DISPLAY=:99`
  - Executes each file in `integration_test/*.dart` individually using:
    - `flutter test integration_test/<file>.dart -d linux --reporter=expanded -v`
  - Uploads per-test logs as artifacts

Environment settings used in CI:
- `CI=true` and `FLUTTER_DISABLE_ANALYTICS=true` to produce clean, non-interactive logs
- `DISPLAY=:99` to target the Xvfb display

Artifacts:
- Unit/widget test log: `unit_widget_tests.log`
- Integration test logs: one log file per test under `integration-tests-logs` artifact

## Running locally

- Install Flutter (stable) and enable Linux desktop if you want to run desktop integration tests:
  ```
  flutter config --enable-linux-desktop
  flutter doctor -v
  ```

- Install Linux dependencies (Ubuntu/Debian example) for desktop tests:
  ```
  sudo apt-get update
  sudo apt-get install -y libgtk-3-0 libgtk-3-dev clang cmake ninja-build pkg-config liblzma-dev xvfb xauth
  ```

- Get dependencies:
  ```
  flutter pub get
  ```

- Run analyzer:
  ```
  flutter analyze
  ```

- Run unit and widget tests with expanded output:
  ```
  flutter test --reporter=expanded -v
  ```

- Run integration tests on Linux desktop headlessly using Xvfb:
  ```
  # Start Xvfb in one terminal
  Xvfb :99 -screen 0 1920x1080x24 &
  export DISPLAY=:99
  export FLUTTER_DISABLE_ANALYTICS=true

  # In project root (preference_frontend):
  flutter config --enable-linux-desktop
  # Run a single file:
  flutter test integration_test/app_launch_e2e_test.dart -d linux --reporter=expanded -v
  # Or loop through all tests:
  for f in integration_test/*.dart; do flutter test "$f" -d linux --reporter=expanded -v; done
  ```

Notes:
- Keep `flutter_lints` at `^5.0.0` (compatible with Dart 3.7.0) as already configured.
- If you add new integration test files under `integration_test/`, CI will pick them up automatically and run each one individually.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
