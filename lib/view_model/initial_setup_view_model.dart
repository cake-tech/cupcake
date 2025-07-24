import 'package:cupcake/utils/alerts/basic.dart';
import 'package:cupcake/view_model/abstract.dart';

class InitialSetupViewModel extends ViewModel {
  @override
  String get screenName => "";

  @override
  bool get hasBackground => true;

  void showTos() {
    showAlert(
      context: c!,
      title: L.terms_of_service,
      body: ["please stop ignoring me on figma i need the ToS screen"],
    );
  }
}
