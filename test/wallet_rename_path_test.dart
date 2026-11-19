import 'package:cupcake/utils/wallet_paths.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('rename keeps the wallet directory', () {
    final current = p.join('/wallets/btc', 'old');
    expect(pathAfterRename(current, 'new'), p.join('/wallets/btc', 'new'));
  });

  test('litecoin rename copies the keys file', () {
    final wallet = p.join('/wallets/ltc', 'old');
    expect(litecoinRenameSource(wallet), '$wallet.keys');
  });

  test('bitcoin rename treats an existing keys file as a name collision', () {
    expect(
      renameCollisionPath('/wallets/btc', 'new', keysFile: true),
      p.join('/wallets/btc', 'new.keys'),
    );
  });
}
