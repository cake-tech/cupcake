import 'package:bip39/bip39.dart' as bip39;

/// Seed used for Litecoin MWEB key derivation.
///
/// Uses the same BIP39 passphrase as the segwit account.
List<int> litecoinMwebSeed(final String mnemonic, final String passphrase) {
  return bip39.mnemonicToSeed(mnemonic, passphrase: passphrase);
}
