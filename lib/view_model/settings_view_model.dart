import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/dev/generate_rebuild.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/view_model/abstract.dart';

part 'settings_view_model.g.dart';

@GenerateRebuild()
class SettingsViewModel extends ViewModel {
  SettingsViewModel();

  @override
  String get screenName => "Settings";

  @ExposeRebuildableAccessors(extraCode: r'$config.save()')
  CupcakeConfig get $config => CupcakeConfig.instance;
}
