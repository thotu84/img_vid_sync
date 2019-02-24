import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:img_vid_storage/translations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as ImageLib;
import 'dart:io' as Io;
import 'package:img_vid_storage/pages/fullscreen_image_page.dart';

enum LoadingStatus {
  CheckPermissions,
  CheckingThumbnails,
  CreatingThumbnails,
  Done,
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  List<FileSystemEntity> _filesList;
  final int _thumbnailsPerRow = 4;
  LoadingStatus _loadingStatus;
  int _loadingCurrent = 0;
  int _loadingTotal = 0;
  Directory _thumbsDir;
  Directory _cameraDir;

  @override
  void initState() {
    super.initState();

    _checkPermissions();
    _loadingStatus = LoadingStatus.CheckPermissions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).homeTitle),
      ),
      body: _createPage(),
    );
  }

  void _createAndGetDirectories() async {
    // Thumbnails directory
    Directory docDir = await getApplicationDocumentsDirectory();
    _thumbsDir = Directory(docDir.path + "/thumbnails");
    if(!await _thumbsDir.exists()) {
      _thumbsDir.createSync();
    }

    // Camera directory
    Directory extDir = await getExternalStorageDirectory();
    String extDirPath = extDir.path;
    _cameraDir = Directory(extDirPath + "/DCIM/Camera");

    _getFilesList();
  }

  Widget _createPage() {
    switch (_loadingStatus) {
      case LoadingStatus.CheckPermissions: {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      case LoadingStatus.CheckingThumbnails: {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(
                padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: Text(Translations.of(context).thumbnailsChecking + " " + _loadingCurrent.toString() + " / " + _loadingTotal.toString()),
              ),
            ],
          ) ,
        );
      }
      case LoadingStatus.CreatingThumbnails: {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(
                padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: Text(Translations.of(context).thumbnailsCreating + " " + _loadingCurrent.toString() + " / " + _loadingTotal.toString()),
              ),
            ],
          ) ,
        );
      }
      case LoadingStatus.Done: {
        return Column(
          children: <Widget>[
            RaisedButton(
              child: Text("Recreate thumbnails"),
              onPressed: () {
                _recreateThumbnails();
              },
            ),

            Expanded(
              child: _thumbnailList(),
            ),
          ],
        );
      }
    }
  }

  double _imageSize() {
    double margin = 4.0;
    double screenWidth = MediaQuery.of(context).size.width;
    return ((screenWidth / _thumbnailsPerRow.toDouble()).floorToDouble()) - margin * 2;
  }

  Widget _thumbnailRow(int rowIndex) {
    double margin = 4.0;
    double thumbnailBorderRadius = 8.0;

    int startIndex = rowIndex * _thumbnailsPerRow;

    List<Widget> thumbnails = [];
    for(int i = 0; i < _thumbnailsPerRow; i++) {
      int currentIndex = startIndex + i;

      if(currentIndex < _filesList.length) {
        if(_filesList[currentIndex].path.endsWith(".jpg")) {

          List<String> split = _filesList[currentIndex].path.split("/");
          String fileName = split[split.length - 1];
          String thumbnailPath = _thumbsDir.path + "/" + fileName;
          File thumbFile = File(thumbnailPath);
          thumbnails.add(
            Padding(
              padding: EdgeInsets.all(margin),
              child: GestureDetector(
                child: Container(
                  width: _imageSize(),
                  height: _imageSize(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(thumbnailBorderRadius)),
                    child: Image.file(
                      thumbFile,
                      width: _imageSize(),
                      height: _imageSize(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onTap: () {

                  Navigator.push(context, MaterialPageRoute(
                      builder: (BuildContext context) =>
                          FullScreenImagePage(imagePath: _filesList[currentIndex].path))
                  );
                },
              ),

            ),

          );
        } else {
          thumbnails.add(
              Container(
                margin: EdgeInsets.all(margin),
                width: _imageSize(),
                height: _imageSize(),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(thumbnailBorderRadius)),
                  border: Border.all(color: Colors.black),
                ),
                child: Icon(FontAwesomeIcons.video),
              )
          );
        }
      } else {
        thumbnails.add(
            Container(
              margin: EdgeInsets.all(margin),
              width: _imageSize(),
              height: _imageSize(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(thumbnailBorderRadius)),
              ),
            )
        );
      }
    }

    return Row(
      children: thumbnails,
    );
  }

  Widget _thumbnailList() {
    return new ListView.builder(
      itemBuilder: (BuildContext context, int index) => _thumbnailRow(index),
      itemCount: _filesList == null ? 0 : (_filesList.length/_thumbnailsPerRow.toDouble()).ceil(),
    );
  }

  void _checkPermissions() async {
    setState(() {
      _loadingStatus = LoadingStatus.CheckPermissions;
    });

    if(await PermissionHandler().checkPermissionStatus(PermissionGroup.storage) == PermissionStatus.granted) {
      _createAndGetDirectories();
    } else {
      Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      if(permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        _createAndGetDirectories();
      } else {
        if(await PermissionHandler().shouldShowRequestPermissionRationale(PermissionGroup.storage)) {
          _showStoragePermissionDialog(true);
        } else {
          _showStoragePermissionDialog(false);
        }
      }
    }
  }

  void _showStoragePermissionDialog(bool rationale) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Translations.of(context).permissionRequiredTitle),
            content: Text(Translations.of(context).permissionReadExternalStorageRequiredText),
            actions: <Widget>[
              rationale == true
                  ?
              // Ok button to retry
              FlatButton(
                child: Text(Translations.of(context).Ok),
                onPressed: () {
                  Navigator.of(context).pop();
                  _checkPermissions();
                },
              )
                  :
              // Open settings button
              FlatButton(
                child: Text(Translations.of(context).permissionOpenSettings),
                onPressed: () {
                  Navigator.of(context).pop();
                  PermissionHandler().openAppSettings();
                },
              )


            ],
          );
        }
    );
  }

  void _getFilesList() {
    _filesList = _cameraDir.listSync();
    _checkThumbNails();
  }

  void _checkThumbNails() {
    setState(() {
      _loadingStatus = LoadingStatus.CheckingThumbnails;
    });

    List<FileSystemEntity> thumbsList = _thumbsDir.listSync();
    List<FileSystemEntity> missingThumbnails = [];

    _loadingCurrent = 0;
    _loadingTotal = _filesList.length;


    for(FileSystemEntity file in _filesList) {
      setState(() {
        ++_loadingCurrent;
      });

      if(file.path.endsWith(".jpg")) {
        List<String> splitFile = file.path.split("/");
        String fileName = splitFile[splitFile.length - 1];

        bool thumbnailExists = false;
        for (FileSystemEntity thumbFile in thumbsList) {
          List<String> splitThumb = thumbFile.path.split("/");
          String thumbName = splitThumb[splitThumb.length - 1];
          if(fileName == thumbName) {
            thumbnailExists = true;
            break;
          }
        }

        if(!thumbnailExists) {
          missingThumbnails.add(file);
        }
      }
    }

    _createThumbnails(missingThumbnails);

  }

  void _createThumbnails(List<FileSystemEntity> missingThumbnails) async {
    setState(() {
      _loadingStatus = LoadingStatus.CreatingThumbnails;
    });

    _loadingCurrent = 0;
    _loadingTotal = missingThumbnails.length;
    for(FileSystemEntity missingFile in missingThumbnails) {

      setState(() {
        ++_loadingCurrent;
      });


      List<String> splitFile = missingFile.path.split("/");
      String fileName = splitFile[splitFile.length - 1];
      String thumbLocation = _thumbsDir.path + "/" + fileName;

      List<dynamic> params = [];
      params.add(missingFile);
      params.add(_imageSize()*6);
      List<int> imageBytes = await compute(createThumbnail, params);

      await Io.File(thumbLocation).writeAsBytes(imageBytes);
    }

    setState(() {
      _loadingStatus = LoadingStatus.Done;
    });
  }

  static List<int> createThumbnail(List<dynamic> params) {
    ImageLib.Image image = ImageLib.decodeImage(Io.File(params[0].path).readAsBytesSync());
    ImageLib.Image thumbnail = ImageLib.copyResize(image, params[1].ceil());

    return ImageLib.encodeJpg(thumbnail);
  }

  void _recreateThumbnails() {
    List<FileSystemEntity> thumbsList = _thumbsDir.listSync();

    for(FileSystemEntity thumbnail in thumbsList) {
      if(thumbnail.path.endsWith(".jpg")) {
        thumbnail.deleteSync();
      }
    }

    _checkThumbNails();
  }
}