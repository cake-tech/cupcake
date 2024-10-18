import 'package:cupcake/utils/config.dart';
import 'package:cupcake/view_model/abstract.dart';

class SettingsViewModel extends ViewModel {
  SettingsViewModel();

  @override
  String get screenName => "Settings";

  CupcakeConfig get appConfig => config;
}
