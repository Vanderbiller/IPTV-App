class Show {
  final String title;
  final String logo;
  final String category;
  final Map<String, List<Episode>> seasons;

  Show({
    required this.title,
    required this.logo,
    required this.category,
    required this.seasons,
  });
}

class Episode {
  final String title;
  final String url;
  final String logo;

  Episode({
    required this.title,
    required this.url,
    required this.logo,
  });
}