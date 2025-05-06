import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hci/controllers/smartkitcontroller.dart';

class PianoPage extends StatefulWidget {
  const PianoPage({super.key});

  @override
  State<StatefulWidget> createState() => _PianoPageState();
}

class _PianoPageState extends State<PianoPage> {
  final smartKitController = Get.find<SmartKitController>();
  static const int keys = 7;
  double get keyWidth => 80 + (80 * _widthRatio);
  double _widthRatio = 0.5;
  final bool _showLabels = true;

  @override
  void didChangeDependencies() {
    double screenWidth = MediaQuery.of(context).size.width;
    _widthRatio = (screenWidth - 80 * keys - 28) / (80 * keys);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildKey("C", false),
              _buildKey("D", false),
              _buildKey("E", false),
              _buildKey("F", false),
              _buildKey("G", false),
              _buildKey("A", false),
              _buildKey("B", false),
            ],
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 100,
            top: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(width: keyWidth * .5),
                _buildKey("1", true),
                _buildKey("2", true),
                Container(width: keyWidth),
                _buildKey("3", true),
                _buildKey("4", true),
                _buildKey("5", true),
                Container(width: keyWidth * .5),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: FloatingActionButton(
          onPressed: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }

  static const accidentals = {
    "1": "C#",
    "2": "D#",
    "3": "F#",
    "4": "G#",
    "5": "A#",
  };

  Widget _buildKey(String id, bool accidental) {
    final pitchName = accidentals[id] ?? id;
    final pianoKey = Stack(
      children: <Widget>[
        Semantics(
          button: true,
          hint: pitchName,
          child: Material(
            borderRadius: borderRadius,
            color: accidental ? Colors.black : Colors.white,
            child: InkWell(
              borderRadius: borderRadius,
              highlightColor: Colors.grey,
              onTap: () {},
              onTapDown: (_) => smartKitController.write(id),
            ),
          ),
        ),
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 20.0,
          child: IgnorePointer(
            child:
              _showLabels ? 
                Text(
                  pitchName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !accidental ? Colors.black : Colors.white,
                  ),
                )
              : 
                Container(),
          ),
        ),
      ],
    );
    if (accidental) {
      return Container(
        width: keyWidth,
        margin: EdgeInsets.symmetric(horizontal: 2.0),
        padding: EdgeInsets.symmetric(horizontal: keyWidth * .1),
        child: Material(
          elevation: 6.0,
          borderRadius: borderRadius,
          shadowColor: Color(0x802196F3),
          child: pianoKey,
        ),
      );
    }
    return Container(
      width: keyWidth,
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      child: pianoKey,
    );
  }

  static const BorderRadius borderRadius = BorderRadius.only(
    bottomLeft: Radius.circular(10.0),
    bottomRight: Radius.circular(10.0),
  );
}
