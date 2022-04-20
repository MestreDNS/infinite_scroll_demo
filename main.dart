import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> foxImages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchFive();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchFive();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Scroll Demo'),
      ),
      body: ListView.builder(
          controller: _scrollController,
          itemCount: foxImages.length,
          itemBuilder: (BuildContext context, index) {
            return SimpleFox(
              foxImage: foxImages[index],
            );
          }),
    );
  }

  fetch() async {
    final response = await http.get(Uri.parse('https://randomfox.ca/floof/'));
    if (response.statusCode == 200) {
      setState(() {
        foxImages.add(json.decode(response.body)['image']);
      });
    }
  }

  fetchFive() {
    for (int i = 0; i < 5; i++) {
      fetch();
    }
  }
}

class SimpleFox extends StatelessWidget {
  const SimpleFox({Key? key, required this.foxImage}) : super(key: key);

  final String foxImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FoxDetail(
                    foxImage: foxImage,
                  )),
        );
      }),
      child: Hero(
        tag: foxImage,
        child: Image.network(
          foxImage,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            int? _totalBytes = loadingProgress.expectedTotalBytes;
            double? _downloadProgress;
            if (_totalBytes != null) {
              _downloadProgress =
                  (((loadingProgress.cumulativeBytesLoaded * 100) /
                              _totalBytes) /
                          100)
                      .toDouble();
            }

            return SizedBox(
              height: 150,
              child: Center(
                child: LinearProgressIndicator(value: _downloadProgress),
              ),
            );
          },
          height: 150,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}

class FoxDetail extends StatelessWidget {
  const FoxDetail({Key? key, required this.foxImage}) : super(key: key);
  final String foxImage;
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: foxImage,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detailed Fox Page'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: (() => Navigator.pop(context)),
                  child: Image.network(
                    foxImage,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('This is a Fox'),
                          Text(foxImage),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
