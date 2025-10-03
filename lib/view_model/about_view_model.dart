import 'package:cupcake/view_model/abstract.dart';
import 'package:mobx/mobx.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'about_view_model.g.dart';

class AboutViewModel = AboutViewModelBase with _$AboutViewModel;

abstract class AboutViewModelBase extends ViewModel with Store {
  AboutViewModelBase();

  @override
  String get screenName => L.about_the_app;

  @observable
  String appName = '';

  @observable
  String version = '';

  @observable
  String buildNumber = '';

  @observable
  bool isLoading = true;

  @action
  Future<void> loadAppInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appName = packageInfo.appName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
      isLoading = false;
    } catch (e) {
      isLoading = false;
    }
  }

  @computed
  String get fullVersion => "$version+$buildNumber";
}
