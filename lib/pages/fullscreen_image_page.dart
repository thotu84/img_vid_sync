import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class FullScreenImagePage extends StatefulWidget{

  final String imagePath;

  FullScreenImagePage({Key key, @required this.imagePath}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FullScreenImagePageState();
  }
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {

  double _maxScale = 20.0;
  double _minScale = 1.0;
  double _scale = 1.0;
  double _previousScale = 1.0;

  Offset _offset;
  Offset _startingOffset;
  Offset _initialOffsetDiff;

  Image _image;

  @override
  void initState() {
    _loadImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return GestureDetector(
        onScaleStart: (ScaleStartDetails details) {
          _previousScale = _scale;

          if(_offset == null) {
            _offset = details.focalPoint;
          }

          // Focal point is in the middle when we're at minscale
          if(_scale <= _minScale) {
            _offset = details.focalPoint;
          }

          _startingOffset = details.focalPoint;
          _initialOffsetDiff = _startingOffset - _offset;
        },

        onScaleUpdate: (ScaleUpdateDetails details) {
          // Updated scale
          double updatedScale = _previousScale * details.scale;
          if(updatedScale >= _maxScale) {
            updatedScale = _maxScale;
          } else if(updatedScale <= _minScale) {
            updatedScale = _minScale;
          }


          Offset updatedOffset = details.focalPoint - _initialOffsetDiff;


          setState(() {
            _scale = updatedScale;
            _offset = updatedOffset;
          });
        },

        onScaleEnd: (ScaleEndDetails details) {
        },

        child: Container(
          child:
          _offset == null
              ?
          Image.file(File(widget.imagePath))
              :
          new Transform(
            transform: new Matrix4.diagonal3(
                Vector3(_scale, _scale, _scale)),
            origin: _offset,
            child: Image.file(File(widget.imagePath)),
          ),
        ),
      );
    }
  }

  static Image _loadImageFromPath(String imagePath) {
    return Image.file(File(imagePath));
  }

  void _loadImage() async {
    Image image = await _loadImageFromPath(widget.imagePath);
    setState(() {
      _image = image;
    });
  }
}