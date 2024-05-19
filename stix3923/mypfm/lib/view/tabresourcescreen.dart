import 'package:flutter/material.dart';
import 'package:mypfm/model/user.dart';
import 'package:mypfm/view/resourcedetailsscreen.dart';
import 'package:xml/xml.dart' as xml;
import 'package:mypfm/model/article.dart';
import 'package:http/http.dart' as http;

class TabResourceScreen extends StatefulWidget {
  final User user;
  const TabResourceScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TabResourceScreen> createState() => _TabResourceScreenState();
}

class _TabResourceScreenState extends State<TabResourceScreen> {
  List<Article> articles = [];

  @override
  void initState() {
    super.initState();
    fetchRssFeed();
  }

  Future<void> fetchRssFeed() async {
    final response = await http.get(Uri.parse('https://medium.com/feed/tag/personal-finance'));

    if (response.statusCode == 200) {
      print('medium response.statusCode == 200');
      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      setState(() {
        articles = items.map((item) {
          final title = item.findElements('title').single.text;
          final description = item.findElements('description').single.text;
          final link = item.findElements('link').single.text;
          final pubDate = item.findElements('pubDate').single.text;
          final creator = item.findElements('dc:creator').isNotEmpty
              ? item.findElements('dc:creator').single.text
              : 'Unknown';

          // Extract image URL from description
          final RegExp imgRegExp = RegExp(r'<img src="(.*?)"');
          final match = imgRegExp.firstMatch(description);
          final imageUrl = match != null ? match.group(1) : null;

          // Clean the description to remove HTML tags
          final cleanDescription = description.replaceAll(RegExp(r'<[^>]*>'), '');

          return Article(
            title: title,
            description: cleanDescription,
            link: link,
            pubDate: pubDate,
            image: imageUrl,
            creator: creator,
          );
        }).toList();
      });
    } else {
      throw Exception('Failed to load RSS feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return articles.isEmpty
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Column(
                children: [
                  ListTile(
                    title: Text(article.title),
                    subtitle: Text(article.pubDate),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResourceDetailsScreen(article: article),
                      ),
                    ),
                  ),
                  const Divider(height: 2),
                ],
              );
            },
          );
  }
}
