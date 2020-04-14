import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoPreview extends StatelessWidget {
  final String imageUrl;

  PhotoPreview({Key key, @required this.imageUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Photo Preview',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new FullPreview(url: imageUrl),
    );
    ;
  }
}

class FullPreview extends StatefulWidget {
  final String url;

  FullPreview({Key key, @required this.url}) : super(key: key);

  @override
  State createState() => new FullPreviewState(url: url);
}

class FullPreviewState extends State<FullPreview> {
  final String url;

  FullPreviewState({Key key, @required this.url});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: PhotoView(imageProvider: NetworkImage(url)));
  }
}
