import 'package:cupcake/view_model/abstract.dart';

class URQRDetails {
  URQRDetails(
      {required this.tag, required this.description, required this.values});
  String tag;
  String description;
  List<String> values;
}

class URQRViewModel extends ViewModel {
  URQRViewModel({
    required this.urqrList,
  });

  @override
  String get screenName => "URQR";

  Map<String, List<String>> urqrList;

  late List<String> urqr = urqrList[urqrList.keys.first]!;
}
