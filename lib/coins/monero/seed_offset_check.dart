import 'package:cupcake/utils/types.dart';

/// Whether wallet creation should stop because the seed offset and its
/// confirmation differ.
///
/// New wallets are checked, and so is a restore that includes a seed. Restoring
/// from keys does not use the offset fields.
bool seedOffsetMismatchBlocksCreate({
  required final CreateMethod method,
  required final bool restoringFromSeed,
  required final String offset,
  required final String confirm,
}) {
  if (offset == confirm) return false;
  if (method == CreateMethod.create || restoringFromSeed) return true;
  return false;
}
