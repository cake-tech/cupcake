class URQrProgress {
  int expectedPartCount;
  int processedPartsCount;
  List<int> receivedPartIndexes;
  double percentage;

  URQrProgress({
    required this.expectedPartCount,
    required this.processedPartsCount,
    required this.receivedPartIndexes,
    required this.percentage,
  });

  bool equals(final URQrProgress? progress) {
    if (progress == null) {
      return false;
    }
    return processedPartsCount == progress.processedPartsCount;
  }
}
