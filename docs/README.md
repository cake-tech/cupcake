# Cupcake Notes and Documentation

> This document is intended for developers. If you just want to build Cupcake, please see the top-level `README.md` and `Makefile`.

## Project Structure

Cupcake adheres to a standard project structure; currently, everything resides inside the `lib` directory. This setup may change in the future.

## `lib/coins`

This directory contains the abstract `coin` definition. To add a new currency to Cupcake, simply implement the abstract `Coin` class found here and update `lib/coins/list.dart` with the new class. The app will automatically pick it up, and a new entry will appear on the coin selection screen during creation or restoration.

> **NOTE:** Currently, only one coin is supported. To ensure a smooth user experience, Cupcake will not prompt the user to select an option if there is only one available.

## `lib/dev`

Cupcake's state management is implemented in a very simple way using MVVM. Since the app is designed to work entirely offline, its state doesn't change often. To keep the code simple, I opted to create an in-house state management solution instead of using an existing one-size-fits-all package. While those packages are great, I believe they would be overkill for an app with a minimal UI and limited processing.

This directory contains three code generation utilities that, while entirely optional, make my life much easier and the code much simpler. For example, instead of converting between `ObservableList` and `List` or wrapping widgets to notify about state changes, we simply trigger a rebuild.

### `@GenerateRebuild()`

Place this annotation around a class to ensure that all other generation annotations work correctly.

### `@RebuildOnChange()`

This annotation wraps a variable in a getter and setter that triggers a rebuild when the variable changes.

```dart
@RebuildOnChange()
Barcode? $barcode;
```

You can then use `barcode` (or `viewModel.barcode`), and updating this value will rebuild the UI.

### `@ThrowOnUI(message: "message...", L: "translation_key")`

If you have a function that may throw an error—and that error should be presented to the user in a dismissible manner—use this annotation. It indicates that something went wrong, allowing the user to retry or correct the issue without restarting the entire action.

```dart
@ThrowOnUI(message: "Error handling URQR scan")
Future<void> $handleUR() async {
  if (formInvalid) {
    throw Exception("The form is invalid");
  }
  await wallet.handleUR(c!, ur);
}
```

You can use either `message:` or `L:`. The `message:` text will be displayed in plain text, whereas `L:` will use a translation key. The error message will appear as a dismissible alert.

If you do not use `@ThrowOnUI()`, you must wrap the function in a try-catch block. If an error is thrown without being caught, the app will display a panic handler screen that prevents further use.

### `@ExposeRebuildableAccessors()`

This annotation is somewhat special and is designed for the settings page. It exposes all setters and getters from a class instance, making it possible to access them as elements of the ViewModel.

```dart
@ExposeRebuildableAccessors(extraCode: r'$config.save()')
CupcakeConfig get $config => CupcakeConfig.instance;
```

This approach lets you access settings, for example, using `viewModel.configBiometricEnabled`. It may be overkill, but I like it because it essentially removes almost all logic from the settings view model.

## `lib/gen`

The `lib/gen` directory uses `flutter_gen` to access assets. This method is preferable to using string-based paths in UI code, as it prevents accidental typos that might not be caught by the linter or at compile time.