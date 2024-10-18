import 'package:cup_cake/utils/config.dart';
import 'package:cup_cake/view_model/abstract.dart';

class SettingsViewModel extends ViewModel {
  SettingsViewModel();

  @override
  String get screenName => "Settings";

  CupcakeConfig get appConfig => config;
}
