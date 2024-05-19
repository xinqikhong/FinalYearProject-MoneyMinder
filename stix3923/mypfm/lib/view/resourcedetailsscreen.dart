import 'package:flutter/material.dart';
import 'package:mypfm/model/article.dart';

class ResourceDetailsScreen extends StatefulWidget {
  final Article article;
  const ResourceDetailsScreen({Key? key, required this.article})
      : super(key: key);

  @override
  State<ResourceDetailsScreen> createState() => _ResourceDetailsScreenState();
}

class _ResourceDetailsScreenState extends State<ResourceDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Resource Details',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.article.image != null)
                Image.network(widget.article.image!),
              SizedBox(height: 16.0),
              Text(
                widget.article.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'By ${widget.article.creator} on ${widget.article.pubDate}',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16.0),
              Text(widget.article.description),
            ],
          ),
        ),
      ),
    );
  }
}
