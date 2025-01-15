# Development Notes

## Known Issues and Workarounds

### Flutter Web Input Handling in Debug Mode

When running the app in debug mode (`flutter run -d chrome`), you may encounter pointer binding errors in the console:
```
DartError: Assertion failed:
org-dartlang-sdk:///lib/_engine/engine/pointer_binding/event_position_helper.dart:70:10
targetElement == domElement
"The targeted input element must be the active input element"
```

**Workaround:**
- These errors are debug-mode specific and do not affect the production build
- To test input handling without these errors, run the app in release mode:
  ```bash
  flutter run -d chrome --release
  ```
- Use debug mode when you need developer tools and hot reload
- Use release mode when testing input handling and form interactions

## Development Commands

### Running the App
- Debug mode: `flutter run -d chrome`
- Release mode: `flutter run -d chrome --release`
- Profile mode: `flutter run -d chrome --profile`
