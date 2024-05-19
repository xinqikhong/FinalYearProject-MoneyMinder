class Article {
  final String title;
  final String description;
  final String link;
  final String pubDate;
  final String? image;
  final String? creator;

  Article({
    required this.title,
    required this.description,
    required this.link,
    required this.pubDate,
    this.image,
    this.creator,
  });
}