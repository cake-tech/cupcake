import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:cupcake/coins/abstract/address.dart';
import 'package:cupcake/coins/zcash/address_type.dart';
import 'package:cupcake/coins/zcash/coin.dart';
import 'package:cupcake/coins/zcash/wallet.dart';
import 'package:cupcake/utils/encryption/default.dart';
import 'package:zkool/src/rust/api/account.dart' as zkool_account;
import 'package:zkool/src/rust/api/coin.dart' as zkool_coin;
import 'package:zkool/src/rust/frb_generated.dart' as zkool_frb;

import 'package:path/path.dart' as p;

class ZcashCachedWalletState {
  ZcashCachedWalletState({
    required this.addresses,
    required this.connectCakeWalletQRCode,
    required this.seed,
    required this.passphrase,
    required this.viewKey,
  });
  final List<Address> addresses;
  final String connectCakeWalletQRCode;
  final String seed;
  final String passphrase;
  final String viewKey;
}

class ZcashUtils {
  ZcashUtils({
    required this.password,
    required this.walletName,
  });

  var c = zkool_coin.Coin();

  Future<int> getCurrentAccountId() async {
    final list = await zkool_account.listAccounts(c: c);
    int lastId = 0;
    for (var i = 0; i < list.length; i++) {
      lastId = list[i].id;
    }
    return lastId;
  }

  Future<List<Address>> getAddresses() async {
    await init();
    final addrs = await zkool_account.getAddresses(
      uaPools: 7,
      account: await getCurrentAccountId(),
      c: c,
    );
    return [
      Address(UnifiedAddressLabel(), addrs.ua ?? "ua"),
      Address(IronwoodAddressLabel(), addrs.oaddr ?? "o"),
      Address(TransparentAddressLabel(), addrs.taddr ?? "t"),
    ];
  }

  Future<String> getSeed() async {
    await init();
    final seed = await zkool_account.getAccountSeed(
      account: await getCurrentAccountId(),
      c: c,
    );
    return seed?.mnemonic ?? "";
  }

  Future<String> getPassphrase() async {
    await init();
    final seed = await zkool_account.getAccountSeed(
      account: await getCurrentAccountId(),
      c: c,
    );
    return seed?.phrase ?? "";
  }

  final String password;
  late final String passwordSha256 = sha256
      .convert(
        utf8.encode(
          password.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''),
        ),
      )
      .toString();
  late final String? dbPassword =
      null; //'cup${password.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}_${passwordSha256}cake';

  String get walletDataDir => Zcash().getPathForWallet(walletName);
  String walletName;

  File get dbFile => File(p.join(walletDataDir, "zcash.db"));
  File get keyFile => File(p.join(walletDataDir, "zcash.keys"));

  static bool _isGlobalInit = false;
  static Future<void> globalInit() async {
    if (_isGlobalInit) return;
    _isGlobalInit = true;
    await zkool_frb.RustLib.init();
  }

  bool _isInit = false;

  Future<void> init() async {
    await globalInit();
    if (_isInit) return;
    _isInit = true;
    // await zkool_network.initDatadir(directory: dbFile.parent.path);
    c = await c.openDatabase(dbFilepath: dbFile.path, password: dbPassword);
    c = c.setLwd(url: "127.0.0.1:7676", serverType: 0);

    await setCache();
  }

  static Future<ZcashUtils> createNewAccount({
    required final String walletName,
    required final String seed,
    required final String passphrase,
    required final String password,
  }) async {
    await globalInit();
    final data = passphrase.isEmpty ? seed : "$seed;$passphrase";
    final keysEncrypted = DefaultEncryption().encryptString(data, password);

    final walletDataDir = Zcash().getPathForWallet(walletName);

    final keyFile = File(p.join(walletDataDir, "zcash.keys"));
    final dbFile = File(p.join(walletDataDir, "zcash.db"));
    keyFile.writeAsBytesSync(keysEncrypted);

    final u = ZcashUtils(
      password: password,
      walletName: walletName,
    );

    u.c = await u.c.openDatabase(dbFilepath: dbFile.path, password: u.dbPassword);

    await zkool_account.newAccount(
      na: zkool_account.NewAccount(
        name: walletName,
        restore: true,
        passphrase: passphrase,
        key: seed,
        aindex: 0,
        birth: 1,
        folder: '',
        useInternal: true,
        internal: false,
        hw: 0,
      ),
      c: u.c,
    );
    u.c = u.c.setLwd(url: "127.0.0.1:7676", serverType: 0);
    u._isInit = true;
    await u.setCache();
    return u;
  }

  ZcashCachedWalletState? cache;

  Future<String> getViewKey() async {
    final ufvk = await zkool_account.getAccountUfvk(
      account: await getCurrentAccountId(),
      pools: 7,
      c: c,
    );
    return ufvk;
  }

  Future<void> setCache() async {
    cache = ZcashCachedWalletState(
      addresses: await getAddresses(),
      connectCakeWalletQRCode: Uri(
        scheme: "zcash-wallet",
        queryParameters: {
          "label": p.basename(walletName),
          "private_key": await getViewKey(),
        },
      ).toString(),
      seed: await getSeed(),
      passphrase: await getPassphrase(),
      viewKey: await getViewKey(),
    );
  }

  late final ZcashWallet wallet = ZcashWallet(u: this);
}
