class URQRData {
  URQRData(
      {required this.tag,
      required this.str,
      required this.progress,
      required this.count,
      required this.error,
      required this.inputs});
  final String tag;
  final String str;
  final double progress;
  final int count;
  final String error;
  final List<String> inputs;
  Map<String, dynamic> toJson() {
    return {
      "tag": tag,
      "str": str,
      "progress": progress,
      "count": count,
      "error": error,
      "inputs": inputs,
    };
  }

  static URQRData parse(List<String> urqr_) {
    final urqr = urqr_.toSet().toList();
    urqr.sort((s1, s2) {
      final s1s = s1.split("/");
      final s1frameStr = s1s[1].split("-");
      final s1curFrame = int.parse(s1frameStr[0]);
      final s2s = s2.split("/");
      final s2frameStr = s2s[1].split("-");
      final s2curFrame = int.parse(s2frameStr[0]);
      return s1curFrame - s2curFrame;
    });

    String tag = '';
    int count = 0;
    String bw = '';
    for (var elm in urqr) {
      final s = elm.substring(elm.indexOf(":") + 1); // strip down ur: prefix
      final s2 = s.split("/");
      tag = s2[0];
      final frameStr = s2[1].split("-");
      // final curFrame = int.parse(frameStr[0]);
      count = int.parse(frameStr[1]);
      final byteWords = s2[2];
      bw += byteWords;
    }
    String? error;

    return URQRData(
      tag: tag,
      str: bw,
      progress: count == 0 ? 0 : (urqr.length / count),
      count: count,
      error: error ?? "",
      inputs: urqr,
    );
  }
}
