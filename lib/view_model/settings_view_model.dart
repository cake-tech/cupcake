import 'package:cupcake/utils/config.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:mobx/mobx.dart';

part 'settings_view_model.g.dart';

class SettingsViewModel = SettingsViewModelBase with _$SettingsViewModel;

abstract class SettingsViewModelBase with ViewModel, Store {
  SettingsViewModelBase();

  @override
  String get screenName => L.settings;

  @observable
  CupcakeConfig config = CupcakeConfig.instance;

  @observable
  int saveCount = 0;

  @action
  void save() {
    saveCount++;
    config.save();
    config = CupcakeConfig.instance;
  }
}
