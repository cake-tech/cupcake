import 'package:cupcake/view_model/abstract.dart';

class URQRViewModel extends ViewModel {
  URQRViewModel({
    required this.urqrList,
  });

  @override
  String get screenName => "URQR";

  final Map<String, List<String>> urqrList;

  // @RebuildOnChange() - not using here due to custom ..removeWhere
  late List<String> _urqr = urqrList[urqrList.keys.first]!;
  List<String> get urqr => _urqr..removeWhere((final elm) => elm.isEmpty);
  set urqr(final List<String> newUrqr) {
    _urqr = newUrqr;
    markNeedsBuild();
  }

  List<String> get alternativeCodes {
    final Map<String, List<String>> copiedList = {};
    copiedList.addAll(urqrList);
    copiedList.removeWhere((final key, final value) =>
        value.join("\n").trim() == urqr.join("\n").trim());
    final keys = copiedList.keys;
    return keys.toList();
  }
}
