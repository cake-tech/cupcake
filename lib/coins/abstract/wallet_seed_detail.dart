import 'package:cupcake/utils/types.dart';

class WalletSeedDetail {
  WalletSeedDetail({
    required this.type,
    required this.name,
    required this.value,
  });

  final WalletSeedDetailType type;
  final String name;
  final String value;
}
