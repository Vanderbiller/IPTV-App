class Profile {
  final String name;
  final String url;
  final String imgPath;

  Profile({required this.name, required this.url, required this.imgPath});

  Map<String, dynamic> toMap() => {
    'name': name,
    'url': url,
    'imgPath': imgPath,
  };

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    name: map['name'] ?? '',
    url: map['url'] ?? '',
    imgPath: map['imgPath'] ?? '',
  );

}