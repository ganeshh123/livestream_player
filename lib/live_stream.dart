class LiveStream {
  final String name;
  final String url;

  LiveStream({required this.name, required this.url});

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
      };

  factory LiveStream.fromJson(Map<String, dynamic> json) {
    return LiveStream(
      name: json['name'],
      url: json['url'],
    );
  }
}
