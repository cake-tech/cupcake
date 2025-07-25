import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/tos_page.dart';

class InitialSetupViewModel extends ViewModel {
  @override
  String get screenName => "";

  @override
  bool get hasBackground => true;

  void showTos() {
    TosPage().push(c!);
  }
}
