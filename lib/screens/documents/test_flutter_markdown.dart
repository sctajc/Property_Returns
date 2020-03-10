import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TestMarkdown extends StatelessWidget {
  static String id = 'test_flutter_markdown_screen';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: rootBundle.loadString("assets/hello.md"),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Markdown(
                data: snapshot.data,
                styleSheet: MarkdownStyleSheet(
                  h1: TextStyle(color: Colors.blue, fontSize: 20),
                  h2: TextStyle(color: Colors.blue, fontSize: 20),
                ),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
