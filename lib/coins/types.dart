typedef ProgressCallback = int Function({String? title, String? description});

enum WalletSeedDetailType {
  text,
  qr,
}

enum CreateMethod {
  any,
  create,
  restore,
}

enum NewWalletActionType {
  nextPage,
  function,
}
