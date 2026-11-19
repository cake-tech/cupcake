import 'package:cupcake/utils/collect_ur_codes.dart';
import 'package:cupcake/utils/urqr.dart';

class AcceptedUrPart {
  const AcceptedUrPart({required this.codes, required this.completed});

  final List<String> codes;
  final bool completed;
}

/// Appends [raw] onto [codes].
///
/// [completed] is true once this part finishes the set, including a one-part code.
AcceptedUrPart acceptUrPart(final List<String> codes, final String raw) {
  final next = collectUrCodes(codes, [raw]);
  return AcceptedUrPart(
    codes: next,
    completed: URQRData.parse(next).progress == 1,
  );
}
