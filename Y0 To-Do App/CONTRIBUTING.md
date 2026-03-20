# Contributing

Thanks for contributing to Y0 To-Do App!

## Requirements
- Flutter SDK 3.5+
- Dart 3.5+
- Android Studio / VS Code

## Setup
1. Fork the repo and create your feature branch.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Quality Targets
- Maintain null-safety and formatting (`dart format`).
- Keep lint warnings at 0 (`flutter analyze`).
- Add tests for new logic (especially repositories and services).

## Testing
```bash
flutter test
```

## Pull Request Checklist
- [ ] Feature or bugfix described in PR summary.
- [ ] New/updated tests added.
- [ ] `flutter analyze` passes.
- [ ] UI changes include accessibility semantics.
