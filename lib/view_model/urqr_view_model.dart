import 'package:cupcake/view_model/abstract.dart';

class URQRViewModel extends ViewModel {
  URQRViewModel({
    required this.urqrList,
  });

  @override
  String get screenName => "URQR";

  Map<String, List<String>> urqrList;

  late List<String> urqr = urqrList[urqrList.keys.first]!;
}
