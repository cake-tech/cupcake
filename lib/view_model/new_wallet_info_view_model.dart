import 'package:cupcake/utils/new_wallet/info_page.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:mobx/mobx.dart';

part 'new_wallet_info_view_model.g.dart';

class NewWalletInfoViewModel = NewWalletInfoViewModelBase with _$NewWalletInfoViewModel;

abstract class NewWalletInfoViewModelBase with ViewModel, Store {
  NewWalletInfoViewModelBase(this.pages);

  @override
  String get screenName => page.topText;

  @observable
  int currentPageIndex = 0;

  @computed
  NewWalletInfoPage get page => pages[currentPageIndex % pages.length];

  final List<NewWalletInfoPage> pages;
}
