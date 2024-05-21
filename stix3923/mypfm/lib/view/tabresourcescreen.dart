import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mypfm/model/user.dart';
import 'package:mypfm/view/resourcedetailsscreen.dart';
import 'package:xml/xml.dart' as xml;
import 'package:mypfm/model/article.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class TabResourceScreen extends StatefulWidget {
  final User user;
  const TabResourceScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TabResourceScreen> createState() => _TabResourceScreenState();
}

class _TabResourceScreenState extends State<TabResourceScreen> {
  List<Article> articles = [];
  final List<String> mediumFeeds = [
    'https://medium.com/feed/tag/personal-finance',
    'https://medium.com/feed/tag/personal-saving',
    'https://medium.com/feed/tag/personal-budget-tips',
    'https://medium.com/feed/tag/budget-tips',
    'https://medium.com/feed/tag/saving-tips',
  ];

  @override
  void initState() {
    super.initState();
    fetchRssFeeds();
  }

  /*Future<void> fetchRssFeed() async {
    final response = await http
        .get(Uri.parse('https://medium.com/feed/tag/personal-finance'));

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
          final cleanDescription =
              description.replaceAll(RegExp(r'<[^>]*>'), '');

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
  }*/

  Future<void> fetchRssFeeds() async {
    // Fetch Medium RSS feed
    for (final feedUrl in mediumFeeds) {
      final mediumResponse = await http.get(Uri.parse(feedUrl));
      if (mediumResponse.statusCode == 200) {
        final mediumDocument = xml.XmlDocument.parse(mediumResponse.body);
        final mediumItems = mediumDocument.findAllElements('item');
        articles
            .addAll(parseMediumArticles(mediumItems)); // Add parsed articles
      } else {
        print('Failed to load Medium RSS feed');
      }
    }
    // Fetch CNBC RSS feed
    /*final cnbcResponse = await http.get(Uri.parse(
        'https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=21324812'));
    if (cnbcResponse.statusCode == 200) {
      final cnbcDocument = xml.XmlDocument.parse(cnbcResponse.body);
      final cnbcItems = cnbcDocument.findAllElements('item');
      articles.addAll(parseCnbcArticles(cnbcItems)); // Add parsed articles
    } else {
      print('Failed to load CNBC RSS feed');
    }*/

    /*
    articles.sort((a, b) {
      try {
        // Try parsing dates (assuming no hidden characters)
        final dateA = DateTime.parse(a.pubDate);
        final dateB = DateTime.parse(b.pubDate);
        return dateB.compareTo(dateA); // Newest first
      } catch (e) {
        print(
            'Error parsing date: ${a.pubDate} vs ${b.pubDate}'); // Log for debugging
        // Handle parsing errors (e.g., skip sorting or assign a default date)
        return 0; // Or any other value if you need to maintain order
      }
    });*/

    setState(() {}); // Update UI after fetching both feeds
  }

  List<Article> parseMediumArticles(Iterable<xml.XmlElement> items) {
    return items.map((item) {
      final title = item.findElements('title').single.text;
      final description = item.findElements('description').single.text;
      final link = item.findElements('link').single.text;
      final pubDate = item.findElements('pubDate').single.text;
      final creator = item.findElements('dc:creator').isNotEmpty
          ? item.findElements('dc:creator').single.text
          : 'Unknown';

      final RegExp imgRegExp = RegExp(r'<img src="(.*?)"');
      final match = imgRegExp.firstMatch(description);
      final imageUrl = match != null ? match.group(1) : null;

      final cleanDescription = description.replaceAll(RegExp(r'<[^>]*>'), '');
      print('finish parseMediumArticles');

      return Article(
        title: title,
        description: cleanDescription,
        link: link,
        pubDate: pubDate,
        image: imageUrl,
        creator: creator,
      );
    }).toList();
  }

  /*List<Article> parseCnbcArticles(Iterable<xml.XmlElement> items) {
    print('start parseCnbcArticles');
    return items.map((item) {
      final link = item.findElements('link').single.text;
      final title = item.findElements('title').single.text;
      final description = item
          .findElements('description')
          .single
          .text
          .replaceAll(RegExp(r'<!\[CDATA\[|\]\]>'), ''); // Remove CDATA tags
      final pubDate = item.findElements('pubDate').single.text;
      print('line 139: $pubDate');
      // Extract creator from metadata element if available
      final creator = item.findElements('metadata:type').isNotEmpty
          ? item.findElements('metadata:type').single.text
          : 'CNBC';
      print('line 144');
      // Try finding image URL within a specific element (replace with the actual element name from CNBC's RSS structure)
      final enclosure = item
          .findElements('enclosure')
          .singleOrNull; // Use singleOrNull to avoid null-throws
      print('line 149');
      final imageUrl = enclosure != null ? enclosure.getAttribute('url') : null;
      print('line 151');
      final cleanDescription = description.replaceAll(RegExp(r'<[^>]*>'), '');
      print('line 153');
      return Article(
        title: title,
        description: cleanDescription,
        link: link,
        pubDate: pubDate,
        image: imageUrl,
        creator: creator,
      );
    }).toList();
  }*/

  @override
  Widget build(BuildContext context) {
    return articles.isEmpty
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              print("77" + article.link);
              //final url = Uri.parse(article.link);
              return Column(
                children: [
                  ListTile(
                    title: Text(article.title),
                    subtitle: Text(article.pubDate),
                    leading: article.image != null
                        ? SizedBox(
                            width: 80.0,
                            height: 80.0,
                            child: Image.network(article.image!))
                        : const SizedBox(
                            width: 80.0,
                            height: 80.0,
                            child: Icon(Icons.rss_feed)),
                    onTap: () async {
                      final Uri url = Uri.parse(article.link);
                      print('Clicked Url(Uri): $url');
                      try {
                        await launchUrl(url, mode: LaunchMode.inAppWebView);
                        print('Launched URL successfully');
                      } on PlatformException catch (e) {
                        print('Launch error: ${e.message}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to launch: ${e.message}'),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(height: 2),
                ],
              );
            },
          );
  }

  /*Future<void> launchURL(String url) async {
    print("93" + url);
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }*/
}
