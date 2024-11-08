extension NullIfEmpty on String {
  String? nullIfEmpty() {
    if (isEmpty) return null;
    return this;
  }
}
