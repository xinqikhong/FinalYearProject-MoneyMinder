/*import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class RssService {
  final String url;

  RssService(this.url);

  Future<List<Article>> fetchArticles() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = XmlDocument.parse(response.body);
      final items = document.findAllElements('item');
      return items.map((item) => Article.fromXmlElement(item)).toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }
}

class Article {
  final String title;
  final String description;
  final String link;

  Article({required this.title, required this.description, required this.link});

  factory Article.fromXmlElement(XmlElement element) {
    final title = element.findElements('title').single.text;
    final description = element.findElements('description').single.text;
    final link = element.findElements('link').single.text;

    return Article(
      title: title,
      description: description,
      link: link,
    );
  }
}*/
