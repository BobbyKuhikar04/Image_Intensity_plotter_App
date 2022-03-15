import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      home: HomePage(),
    );
  }
}

enum ImageSourceType { gallery, camera }

class HomePage extends StatelessWidget {
  void _handleURLButtonPress(BuildContext context, var type) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ImageFromGalleryEx(type)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Image Intensity Plotter",
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
        elevation: 10,
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.search),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.notifications),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),
      drawer: Drawer(),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 0.0),
              child: Container(
                width: 350,
                height: 180,
                child: Image.asset("assests/image.png"),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30.0),
              child: MaterialButton(
                color: Colors.blue,
                elevation: 20,
                minWidth: 350.0,
                height: 100.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0)),
                child: Text(
                  "Pick Image from Gallery",
                  style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                onPressed: () {
                  _handleURLButtonPress(context, ImageSourceType.gallery);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: MaterialButton(
                color: Colors.blue,
                minWidth: 350.0,
                elevation: 20,
                height: 100.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0)),
                child: Text(
                  "Pick Image from Camera",
                  style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                onPressed: () {
                  _handleURLButtonPress(context, ImageSourceType.camera);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'School',
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.pink,
          ),
        ],
        // onTap: _onItemTapped,
      ),
    );
  }
}

class ImageFromGalleryEx extends StatefulWidget {
  final type;

  ImageFromGalleryEx(this.type);

  @override
  ImageFromGalleryExState createState() => ImageFromGalleryExState(this.type);
}

var absimage;
var _image;

String processed = "";

class ImageFromGalleryExState extends State<ImageFromGalleryEx> {
  var imagePicker;
  var type;
  String pathy = "";
  String url = "";
  ImageFromGalleryExState(this.type);

  @override
  void initState() {
    super.initState();
    imagePicker = new ImagePicker();
  }

  uploadImagey() async {
    final request = http.MultipartRequest(
        "POST", Uri.parse('http://172.21.5.157:8000/upload'));
    final headers = {"Content-type": "multipart/form-data"};

    request.files.add(http.MultipartFile(
        'image', _image!.readAsBytes().asStream(), _image!.lengthSync(),
        filename: _image!.path.split("/").last));

    request.headers.addAll(headers);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    print(processed);
    final resJson = await jsonDecode(res.body);
    processed = resJson["processed"];

    /* String pathe = path.join(
      'C:/Users/91799/Desktop/camera app/API/Uploadimages/filename.jpg');
    print(pathe);*/

    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ImageFromUploadEx()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(type == ImageSourceType.camera
              ? "Image from Camera"
              : "Image from Gallery")),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 52,
          ),
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    var source = type == ImageSourceType.camera
                        ? ImageSource.camera
                        : ImageSource.gallery;
                    XFile image = await imagePicker.pickImage(
                        source: source,
                        imageQuality: 50,
                        preferredCameraDevice: CameraDevice.front);

                    setState(() {
                      pathy = image.path;
                      _image = File(image.path);
                    });
                  },
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(color: Colors.red[200]),
                    child: _image != null
                        ? Image.file(
                            _image,
                            width: 400.0,
                            height: 400.0,
                            fit: BoxFit.fitHeight,
                          )
                        : Container(
                            decoration: BoxDecoration(color: Colors.red[200]),
                            width: 200,
                            height: 200,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                            ),
                          ),
                  ),
                ),
                MaterialButton(
                  color: Colors.blue,
                  child: Text(
                    "Upload",
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  onPressed: uploadImagey,
                  // Navigator.of(context).push(MaterialPageRoute(
                  //  builder: (context) => ImageFromUploadEx()));
                ),
                MaterialButton(
                  color: Colors.orange,
                  child: Text(
                    "Crop",
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  onPressed: uploadImagey,
                  // Navigator.of(context).push(MaterialPageRoute(
                  //  builder: (context) => ImageFromUploadEx()));
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ImageFromUploadEx extends StatefulWidget {
  @override
  ImageFromUploadExState createState() => ImageFromUploadExState();
}

class ImageFromUploadExState extends State<ImageFromUploadEx> {
  //var imguploaded = File(processed);
  var rgb = Image.asset("assests/rgb3.png");
  var gray = Image.asset("assests/gray3.png");

  @override
  void initState() {
    super.initState();
    rgb = Image.asset("assests/rgb3.png");
    gray = Image.asset("assests/gray3.png");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PLOT:")),
      body: Column(
        children: <Widget>[
          Center(
            child: Container(
              width: 350,
              height: 300,
              child: gray != null
                  ? gray
                  : Container(
                      width: 260,
                      height: 260,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
            ),
          ),
          Center(
            child: Container(
              width: 350,
              height: 300,
              child: rgb != null
                  ? rgb
                  : Container(
                      width: 350,
                      height: 300,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }
}
