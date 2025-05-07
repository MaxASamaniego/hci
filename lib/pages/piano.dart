import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hci/controllers/smartkitcontroller.dart';

final _whiteNotes = ["C", "D", "E", "F", "G", "A", "B", "J", "K", "L", "M", "N", "H", "I"];
final _accidentals = ["1", "2", "", "3", "4", "5", "", "6", "7", "", "8", "9", "0"];

const _whiteLabels = {
  "C": "C0",
  "D": "D0",
  "E": "E0",
  "F": "F0",
  "G": "G0",
  "A": "A0",
  "B": "B0",
  "J": "C1",
  "K": "D1",
  "L": "E1",
  "M": "F1",
  "N": "G1",
  "H": "A1",
  "I": "B1",
};

const _accidentalsLabels = {
  "1": "C0#",
  "2": "D0#",
  "3": "F0#",
  "4": "G0#",
  "5": "A0#",
  "6": "C1#",
  "7": "D1#",
  "8": "F1#",
  "9": "G1#",
  "0": "A1#",
};

class PianoPage extends StatefulWidget {
  const PianoPage({super.key});

  @override
  State<StatefulWidget> createState() => _PianoPageState();
}

class _PianoPageState extends State<PianoPage> {
  final smartKitController = Get.find<SmartKitController>();
  static final int keys = _whiteNotes.length;
  double get keyWidth => 80 + (80 * _widthRatio);
  double _widthRatio = 0.5;
  final bool _showLabels = true;

  @override
  void didChangeDependencies() {
    double screenWidth = MediaQuery.of(context).size.width;
    _widthRatio = (screenWidth - 80 * keys - (28 * _whiteNotes.length/7)) / (80 * keys);
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
            children: <Widget>[for (var note in _whiteNotes) _buildKey(note, false)],
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
                for (var note in _accidentals) if(note != "") _buildKey(note, true) else Container(width: keyWidth),
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

  Widget _buildKey(String id, bool accidental) {
    final pitchName = accidental ? _accidentalsLabels[id] ?? id : _whiteLabels[id] ?? id;
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
              onTapDown: (_) => smartKitController.write(id),
              onTapUp: (_) => smartKitController.write("g"),
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
