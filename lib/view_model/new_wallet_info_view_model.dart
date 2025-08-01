import 'package:cupcake/utils/new_wallet/info_page.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/new_wallet_info.dart';
import 'package:mobx/mobx.dart';

part 'new_wallet_info_view_model.g.dart';

class NewWalletInfoViewModel = NewWalletInfoViewModelBase with _$NewWalletInfoViewModel;

abstract class NewWalletInfoViewModelBase extends ViewModel with Store {
  NewWalletInfoViewModelBase(this.pages, {this.currentPageIndex = 0});

  @override
  bool get hasBackground => true;

  @override
  String get screenName => page.topText;

  void nextPage() {
    final nextPageIndex = (currentPageIndex + 1) % pages.length;
    NewWalletInfoScreen(pages: pages, currentPageIndex: nextPageIndex).push(c!);
  }

  final int currentPageIndex;

  @computed
  NewWalletInfoPage get page => pages[currentPageIndex % pages.length];

  final List<NewWalletInfoPage> pages;
}
