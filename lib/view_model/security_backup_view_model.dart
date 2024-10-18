import 'package:cupcake/coins/abstract.dart';
import 'package:cupcake/view_model/abstract.dart';

class SecurityBackupViewModel extends ViewModel {
  SecurityBackupViewModel({required this.wallet});

  @override
  // TODO: implement screenName
  String get screenName => L.security_and_backup;

  CoinWallet wallet;
}
