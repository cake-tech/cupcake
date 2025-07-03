import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:mobx/mobx.dart';

part 'urqr_view_model.g.dart';

class URQRViewModel = URQRViewModelBase with _$URQRViewModel;

abstract class URQRViewModelBase extends ViewModel with Store {
  URQRViewModelBase({
    required this.urqrList,
    required this.currentWallet,
  });

  @override
  String get screenName => "URQR";

  final Map<String, List<String>> urqrList;
  final CoinWallet currentWallet;
  @observable
  late List<String> _urqr = urqrList[urqrList.keys.first]!;

  @computed
  List<String> get urqr => _urqr..removeWhere((final elm) => elm.isEmpty);

  @computed
  set urqr(final List<String> newUrqr) {
    _urqr = newUrqr;
  }

  @computed
  List<String> get alternativeCodes {
    final Map<String, List<String>> copiedList = {};
    copiedList.addAll(urqrList);
    copiedList.removeWhere(
      (final key, final value) => value.join("\n").trim() == urqr.join("\n").trim(),
    );
    final keys = copiedList.keys;
    return keys.toList();
  }
}
