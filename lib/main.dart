import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';

// Photo model class
class Photo {
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  Photo({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PhotoListScreen(),
    );
  }
}

class PhotoListScreen extends StatefulWidget {
  const PhotoListScreen({super.key});

  @override
  State<PhotoListScreen> createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  bool _getProductListInProgress = false;
  List<Photo> listphoto = [];

  @override
  void initState() {
    super.initState();
    _getProductInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Gallery App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _getProductInfo,
        child: Visibility(
          visible: !_getProductListInProgress,
          replacement: const Center(
            child: CircularProgressIndicator(),
          ),
          child: ListView.separated(
            itemCount: listphoto.length,
            itemBuilder: (context, index) {
              return _buildPhoto(listphoto[index]);
            },
            separatorBuilder: (_, __) => const Divider(),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto(Photo photo) {
    return SingleChildScrollView(
      child: ListTile(
        leading: Image.network(
          photo.thumbnailUrl,
          height: 60,
          width: 60,
          errorBuilder: (context, error, stackTrace) {
            return Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/1/18/Color-white.JPG',
              height: 60,
              width: 60,
            );
          },
        ),
        title: Text(photo.title),
      ),
    );
  }

  Future<void> _getProductInfo() async {
    _getProductListInProgress = true;
    setState(() {});

    const String productLink = 'https://jsonplaceholder.typicode.com/photos';
    Uri url = Uri.parse(productLink);

    Response response = await get(url);

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final decodeData = jsonDecode(response.body);
      setState(() {
        listphoto = (decodeData as List).map((json) => Photo.fromJson(json)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product GET failed!!!!")));
    }

    _getProductListInProgress = false;
    setState(() {});
  }
}
