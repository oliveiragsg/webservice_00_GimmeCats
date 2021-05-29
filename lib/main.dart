import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_downloader/image_downloader.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Gimme Cats'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static Uri img = Uri.parse('https://cataas.com/cat/says/gatito testador');
  Image placeholderIMG = Image(image: NetworkImage('https://cataas.com/cat/says/gatito testador'));
  var localPath = '';
  int _progress = 0;
  var helloImagePath = '';
  bool catsWorking = false;
  final myController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    img = Uri.parse('https://cataas.com/cat/says/hello there');
    _helloImage();
    ImageDownloader.callback(onProgressUpdate: (String imageId, int progress) {
      setState(() {
        catsWorking = true;
        _progress = progress;
        if(_progress == 100)
          catsWorking = false;
      });
    });

  }

  void _helloImage() async {
    var imageId = await ImageDownloader.downloadImage(img.toString(), destination: AndroidDestinationType.directoryPictures);
    var path = await ImageDownloader.findPath(imageId);
    helloImagePath = path;
    imageCache.clear();
    imageCache.clearLiveImages();

    setState(() {

    });
  }

  void _changeImage() async {
    await _downloadImage();
    imageCache.clear();
    imageCache.clearLiveImages();
    placeholderIMG = Image(
        image: FileImage(File(localPath)));

    setState(() {

    });
  }

  Future<void> _downloadImage() async {
    var imageId = await ImageDownloader.downloadImage(img.toString(), destination: AndroidDestinationType.directoryPictures);
    var path = await ImageDownloader.findPath(imageId);
    localPath = path;
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void _gimmeCat() {
    img = Uri.parse('https://cataas.com/cat');
    _changeImage();
  }

  void _gimmeCatSaying(String say) {
    img = Uri.parse('https://cataas.com/cat/says/' + say);
    _changeImage();
  }

  void _gimmeCatGif() {
    img = Uri.parse('https://cataas.com/cat/gif');
    _changeImage();
  }

  void _openImage() async {
    ImageDownloader.open(localPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title, textAlign: TextAlign.center,)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                  backgroundImage: FileImage(File(helloImagePath)),
                  radius: 80,
              ),
              Container(
                  margin: EdgeInsets.only(top: 15),
                  child: Text('Choose how do you want your cat bellow: ')),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  IconButton(
                      tooltip: 'Click here to get a nice cat picture',
                      iconSize: 50,
                      icon: Icon(Icons.image),
                      onPressed: _gimmeCat),
                  IconButton(
                      tooltip: 'Click here to get a nice cat gif',
                      iconSize: 50,
                      icon: Icon(Icons.gif),
                      onPressed: () {
                        _gimmeCatGif();
                      },),
                  IconButton(
                      tooltip: 'Click here to get a nice cat picture saying what you type bellow',
                      iconSize: 50,
                      icon: Icon(Icons.text_fields),
                      onPressed: () {
                        if(myController.text.isEmpty)
                          {
                            final snackBar = SnackBar(
                              content: Text('You must type something to the cat say first.',
                                textAlign: TextAlign.center,),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        else {
                          _gimmeCatSaying(myController.text); }
                        }
                  ),
                ],),
              ),
              Container(
                width: 300,
                child: TextField(
                    style: TextStyle(
                        fontSize: 20.0,
                        height: 2.0,
                        color: Colors.black
                    ),
                    controller: myController,
                    decoration: InputDecoration(
                    border: OutlineInputBorder(), // Added this
                    contentPadding: EdgeInsets.all(7),
                    hintText: 'What your cat is gonna say?',),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 15),
                child: Visibility(
                    visible: catsWorking,
                    child: Text('The cats are working, please await.\nProgress: $_progress %', textAlign: TextAlign.center)),
              ),
              FutureBuilder(
                future: File(localPath).open(),
                builder: (context, snapshot) {
                  if(snapshot.hasError) {
                    return Container(
                        margin: EdgeInsets.only(top: 15),
                        child: Text('Press one of the three options above to get a cat.'));
                  }
                  else if(snapshot.hasData) {
                    return Container(
                      margin: EdgeInsets.all(12),
                      child: InkWell(
                        onTap: () {
                          final snackBar = SnackBar(
                              content: Text('Hold the image to get your cat.',
                              textAlign: TextAlign.center,),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        onLongPress: () {
                          _openImage();
                        },
                        child: Image(
                            width: 450,
                            height: 450,
                            image: FileImage(File(localPath))),
                      ),
                    );
                  }
                  else {
                    return CircularProgressIndicator();
                  }
                },),
            ],
          ),
        ),
      ),
    );
  }
}