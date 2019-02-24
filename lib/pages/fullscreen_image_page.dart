import 'dart:io';
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

  double _scale = 1.0;
  double _previousScale = 1.0;
  double _previousDX = 0.0;
  double _previousDY = 0.0;
  double _dx = 0.0;
  double _dy = 0.0;
  bool _hasPanned = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (ScaleStartDetails details) {
        _previousScale = _scale;

        if(!_hasPanned) {
          _hasPanned = true;
          _dx = details.focalPoint.dx;
          _dy = details.focalPoint.dy;
          _previousDX = details.focalPoint.dx;
          _previousDY = details.focalPoint.dy;
        } else {
          _previousDX = _dx;
          _previousDY = _dy;
        }

      },
      onScaleUpdate: (ScaleUpdateDetails details){
        setState(() {
          if(_previousScale * details.scale < 1.0) {
            _scale = 1.0;
          } else {
            _scale = _previousScale * details.scale;
          }

          //_dx = _previousDX - (details.focalPoint.dx -_previousDX);
          //_dy = _previousDY + (_previousDY - details.focalPoint.dy);
          _dx = details.focalPoint.dx;
          _dy = details.focalPoint.dy;

        });
      },
      child: Container(
        child: new Transform(
          transform: new Matrix4.diagonal3(Vector3(_scale, _scale, _scale)),
          origin: _getOffset(),
          child: Image.file(File(widget.imagePath),
          ),
        ),
      ),
    );
  }

  Offset _getOffset() {
    if(_dx == 0.0 && _dy == 0.0) {
      return null;
    } else {
      return Offset(_dx, _dy);

    }
  }

}