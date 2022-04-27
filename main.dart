import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> foxImages = [];
  bool loadingType = true;
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
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                foxImages.clear();
                loadingType = !loadingType;
                fetchFive();
              });
            },
            icon: const Icon(Icons.change_circle_outlined),
          )
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 226, 233, 238),
      body: ListView.builder(
          controller: _scrollController,
          itemCount: foxImages.length,
          itemBuilder: (BuildContext context, index) {
            return SimpleFox(
              foxImage: foxImages[index],
              loadingType: loadingType,
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
  const SimpleFox({Key? key, required this.foxImage, required this.loadingType})
      : super(key: key);

  final bool loadingType;
  final String foxImage;

  final double _cardRadius = 8.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: (() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoxDetail(
                foxImage: foxImage,
              ),
            ),
          );
        }),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_cardRadius),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 211, 223, 238),
                spreadRadius: 0,
                blurRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_cardRadius),
            child: Hero(
              tag: foxImage,
              child: Image.network(
                foxImage,
                height: 150,
                fit: BoxFit.fitWidth,
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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: _returnLoading(_downloadProgress),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _returnLoading(double? _downloadProgress) {
    if (loadingType) {
      return const RefreshProgressIndicator();
    } else {
      return LinearProgressIndicator(value: _downloadProgress);
    }
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
        backgroundColor: const Color.fromARGB(255, 226, 233, 238),
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
                        top: BorderSide(width: 3),
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
