import 'package:flutter/material.dart';
import 'package:painter_test/ink_painter.dart';
import 'package:provider/provider.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Painter Example',
      home: ChangeNotifierProvider(
        create: (_) => DigitalInkRecognitionState(),
        child: ExamplePage(),
      ),
    );
  }
}

class ExamplePage extends StatefulWidget {
  @override
  _ExamplePageState createState() => new _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {

  DigitalInkRecognitionState get state => Provider.of(context, listen: false);
  final paddingValue = 8.0;
  String offsetText = "";
  var objectList = [];
  var xList = [];
  var yList = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _actionDown(Offset point) async {
    var x = point.dx.toInt();
    var y = point.dy.toInt();
    print("Scale Start");
    print("x: $x, y: $y");
    xList.add(x);
    yList.add(y);
    state.startWriting(point);
  }

  Future<void> _actionMove(Offset point) async {
    var x = point.dx.toInt();
    var y = point.dy.toInt();
    offsetText = "x: $x, y: $y";
    xList.add(x);
    yList.add(y);
    setState(() {

    });
    state.writePoint(point);
  }

  Future<void> _actionUp() async {
    var tempX = [];
    var tempY = [];
    for (int i = 0; i < xList.length; i++) {
      tempX.add(xList[i]);
      tempY.add(yList[i]);
    }
    objectList.add({
      "x": tempX,
      "y": tempY,
    });
    xList.clear();
    yList.clear();
    print("Scale End");
    print(objectList);
    // TODO STT 좌표 전달 및 결과 받기
    state.stopWriting();
  }

  @override
  Widget build(BuildContext context) {

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Container(
          width: w - paddingValue*2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Builder(
                builder: (_) {
                  _init();
                  return GestureDetector(
                    onScaleStart: (details) async => await _actionDown(details.localFocalPoint),
                    onScaleUpdate: (details) async => await _actionMove(details.localFocalPoint),
                    onScaleEnd: (details) async => await _actionUp(),
                    child: Consumer<DigitalInkRecognitionState>(
                      builder: (_, state, __) => CustomPaint(
                        painter: DigitalInkPainter(writings: state.writings),
                        child: Container(
                          width: w - paddingValue*2,
                          height: h - paddingValue*2 - 100,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Container(
                child: Center(
                  child: Text(offsetText),
                ),
              ),
              ElevatedButton(onPressed: (){
                state.reset();
              }, child: Text("clear")),
            ],
          ),
        ),
      ),
    );
  }

  void _init() async {
    // TODO 인식 모듈 세팅
  }

}

class DigitalInkRecognitionState extends ChangeNotifier {
  List<List<Offset>> _writings = [];
  List<dynamic> _data = [];
  bool isProcessing = false;

  List<List<Offset>> get writings => _writings;
  List<dynamic> get data => _data;
  bool get isNotProcessing => !isProcessing;
  bool get isEmpty => _data.isEmpty;
  bool get isNotEmpty => _data.isNotEmpty;

  List<Offset> _writing = [];

  void reset() {
    _writings = [];
    notifyListeners();
  }

  void startWriting(Offset point) {
    _writing = [point];
    _writings.add(_writing);
    notifyListeners();
  }

  void writePoint(Offset point) {
    if (_writings.isNotEmpty) {
      _writings[_writings.length - 1].add(point);
      notifyListeners();
    }
  }

  void stopWriting() {
    _writing = [];
    notifyListeners();
  }

  void startProcessing() {
    isProcessing = true;
    notifyListeners();
  }

  void stopProcessing() {
    isProcessing = false;
    notifyListeners();
  }

  set data(List<dynamic> data) {
    _data = data;
    notifyListeners();
  }

  @override
  String toString() {
    return isNotEmpty ? _data.first.text : '';
  }

  String toCompleteString() {
    return isNotEmpty ? _data.map((c) => c.text).toList().join(', ') : '';
  }
}