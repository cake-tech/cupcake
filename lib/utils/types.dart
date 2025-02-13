typedef ProgressCallback = int Function({String? title, String? description});

enum WalletSeedDetailType {
  text,
  qr,
}

enum CreateMethod {
  create,
  restore,
}

enum NewWalletActionType {
  nextPage,
  function,
}
