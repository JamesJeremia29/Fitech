//fetch json data field
class ML {
  final String Recommend;

  const ML({
    required this.Recommend,
  });

  factory ML.fromJson(Map<String, dynamic> json) {
    return ML(
      Recommend: json['recommended'],
    );
  }
}
