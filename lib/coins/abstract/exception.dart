class CoinException implements Exception {
  CoinException(this.exception, {this.details});

  String exception;
  String? details;

  @override
  String toString() {
    return "$exception\n$details";
  }
}
