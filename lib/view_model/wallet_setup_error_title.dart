import 'package:cupcake/utils/types.dart';

/// Dialog title for a failed create or restore.
///
/// A restore uses the restore title even when the screen was opened from a
/// flow that can also create a wallet.
String walletSetupErrorTitle({
  required final String createTitle,
  required final String restoreTitle,
  required final CreateMethod? screenMethod,
  required final CreateMethod? formMethod,
}) {
  final method = screenMethod ?? formMethod;
  if (method == CreateMethod.restore) return restoreTitle;
  return createTitle;
}
