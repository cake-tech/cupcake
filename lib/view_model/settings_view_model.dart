import 'package:cupcake/utils/config.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:mobx/mobx.dart';

part 'settings_view_model.g.dart';

class SettingsViewModel = SettingsViewModelBase with _$SettingsViewModel;

abstract class SettingsViewModelBase extends ViewModel with Store {
  SettingsViewModelBase();

  @override
  String get screenName => L.settings;

  final CupcakeConfig _config = CupcakeConfig.instance;

  @observable
  late bool debug = _config.debug;
  @observable
  late int msForQrCode = _config.msForQrCode;
  @observable
  late bool biometricEnabled = _config.biometricEnabled;
  @observable
  late bool canUseInsecureBiometric = _config.canUseInsecureBiometric;

  @observable
  late int maxFragmentLength = _config.maxFragmentLength;

  @action
  void save() {
    _config.debug = debug;
    _config.msForQrCode = msForQrCode;
    _config.biometricEnabled = biometricEnabled;
    _config.canUseInsecureBiometric = canUseInsecureBiometric;
    _config.maxFragmentLength = maxFragmentLength;
    _config.save();
  }
}
