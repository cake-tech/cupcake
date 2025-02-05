import 'package:cupcake/view_model/abstract.dart';

class URQRViewModel extends ViewModel {
  URQRViewModel({
    required this.urqrList,
  });

  @override
  String get screenName => "URQR";

  Map<String, List<String>> urqrList;

  late List<String> _urqr = urqrList[urqrList.keys.first]!;
  List<String> get urqr => _urqr..removeWhere((elm) => elm.isEmpty);
  set urqr(List<String> newUrqr) { 
    _urqr = newUrqr;
    markNeedsBuild();
  }

  List<String> get alternativeCodes {
final Map<String, List<String>> copiedList = {};
    copiedList.addAll(urqrList);
    copiedList.removeWhere((key, value) =>
        value.join("\n").trim() == urqr.join("\n").trim());
    final keys = copiedList.keys;
    return keys.toList();
  }
}
