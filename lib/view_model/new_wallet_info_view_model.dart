import 'package:cupcake/dev/generate_rebuild.dart';
import 'package:cupcake/utils/new_wallet/info_page.dart';
import 'package:cupcake/view_model/abstract.dart';

part 'new_wallet_info_view_model.g.dart';

@GenerateRebuild()
class NewWalletInfoViewModel extends ViewModel {
  NewWalletInfoViewModel(this.pages);

  @override
  String get screenName => page.topText;

  NewWalletInfoPage get page => pages[currentPageIndex % pages.length];

  final List<NewWalletInfoPage> pages;

  @RebuildOnChange()
  int $currentPageIndex = 0;
}
