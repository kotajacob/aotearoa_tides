import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class PortPage extends StatefulWidget {
  const PortPage({
    Key? key,
  }) : super(key: key);

  @override
  _PortPageState createState() => _PortPageState();
}

class _PortPageState extends State<PortPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _currentPort = "Loading";
  List<dynamic> _tides = [];

  @override
  void initState() {
    super.initState();
    getPort();
  }

  getPort() async {
    final SharedPreferences prefs = await _prefs;
    var currentPort = prefs.getString("port") ?? "Wellington";

    String data =
        await DefaultAssetBundle.of(context).loadString(ports[currentPort]!);
    final jsonResult = jsonDecode(data);

    setState(() {
      // Attempt to load saved port. Fallback to capital.
      _currentPort = currentPort;
      _tides = jsonResult;
    });
  }

  setPort(String port) async {
    String data = await DefaultAssetBundle.of(context).loadString(ports[port]!);
    final jsonResult = jsonDecode(data);

    setState(() {
      // Attempt to load saved port. Fallback to capital.
      _currentPort = port;
      _tides = jsonResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPort == "Loading") {
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: const Center(
          child: Text(
            "Loading...",
            style: TextStyle(
              fontSize: 56,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            flexibleSpace: const FlexibleSpaceBar(
              background: Padding(
                padding: EdgeInsets.only(top: 90.0),
                child: Image(image: AssetImage('images/boat_scene.png')),
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              _currentPort,
              style: const TextStyle(
                fontSize: 26,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.map,
                  color: Colors.white,
                  size: 28.0,
                ),
                onPressed: () {
                  _pushMap(context);
                },
                tooltip: 'Select a Port',
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                QuickInfo(
                  height: _printHeight(),
                  rising: _isRising(),
                  duration: _printDuration(),
                ),
                CardInfo(
                  tides: _tides,
                  currentTideID: _nextTideID(),
                ),
                const Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pushMap(BuildContext context) async {
    final SharedPreferences prefs = await _prefs;

    final String nextPageValue = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PortList()),
    );

    await prefs.setString('port', nextPageValue);
    setPort(nextPageValue);
  }

  // _nextTideID uses the current time to find the next tide for the current
  // _tides field. If no valid tides can be found 0 is returned.
  int _nextTideID() {
    final now = DateTime.now();
    for (int i = 0; i < _tides.length; i++) {
      final nextTide = _tides[i];
      final nextTime = DateTime.parse(nextTide["Time"]);

      if (nextTime.isAfter(now)) {
        return i;
      }
    }
    return 0;
  }

  // _height calculates the tide height using the previous and future
  // tide heights. The forumla comes from:
  // https://www.linz.govt.nz/sea/tides/tide-predictions/how-calculate-tide-times-heights
  // If the height cannot be calculated double.nan is returned.
  double _height() {
    final now = DateTime.now();
    for (int i = 0; i < _tides.length; i++) {
      final nextTide = _tides[i];
      final nextTime = DateTime.parse(nextTide["Time"]);

      if (nextTime.isAfter(now)) {
        final prevTide = _tides[i - 1];
        final prevTime = DateTime.parse(prevTide["Time"]);

        final nowDouble = now.millisecondsSinceEpoch.toDouble();
        final prevDouble = prevTime.millisecondsSinceEpoch.toDouble();
        final nextDouble = nextTime.millisecondsSinceEpoch.toDouble();
        final prevHeight = prevTide["Height"];
        final nextHeight = nextTide["Height"];

        final a =
            pi * (((nowDouble - prevDouble) / (nextDouble - prevDouble)) + 1);
        final height =
            prevHeight + (nextHeight - prevHeight) * ((cos(a) + 1) / 2);

        return height;
      }
    }
    return double.nan;
  }

  // _printHeight formats the current height as a count of meters or returns a
  // blank string if an error occurs.
  String _printHeight() {
    final height = _height();

    // Return blank string if tides are not loaded.
    if (height.isNaN) {
      return "";
    }

    return height.toStringAsPrecision(2) + "m";
  }

  String _printDuration() {
    final i = _nextTideID();
    if (i == 0) {
      // Early exit if the tide height cannot be found.
      return "";
    }

    final nextTide = _tides[i];
    final nextTime = DateTime.parse(nextTide["Time"]).toLocal();

    var minute = nextTime.minute;
    var hour = nextTime.hour;
    var minutePadding = minute < 10 ? "0" : "";

    return " at $hour:$minutePadding$minute";
  }

  bool _isRising() {
    final i = _nextTideID();
    if (i == 0) {
      // Early exit if the tide cannot be found.
      return false;
    }

    final nextTide = _tides[i];
    final prevTide = _tides[i - 1];

    if (nextTide["Height"] > prevTide["Height"]) {
      return true;
    } else {
      return false;
    }
  }
}

class QuickInfo extends StatefulWidget {
  const QuickInfo({
    required this.height,
    required this.rising,
    required this.duration,
    Key? key,
  }) : super(key: key);
  final String height;
  final bool rising;
  final String duration;

  @override
  _QuickInfoState createState() => _QuickInfoState();
}

class _QuickInfoState extends State<QuickInfo> {
  final _textStyle = const TextStyle(fontSize: 46, color: Colors.white);
  final _textStyleSmall = const TextStyle(fontSize: 36, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    var height = widget.height;
    var rising = widget.rising;
    var duration = widget.duration;
    IconData _arrow;

    if (rising) {
      _arrow = Icons.arrow_upward;
    } else {
      _arrow = Icons.arrow_downward;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              height,
              style: _textStyle,
            ),
          ),
          Icon(
            _arrow,
            color: Colors.white,
            size: 36.0,
          ),
          Text(
            duration,
            style: _textStyleSmall,
          ),
        ],
      ),
    );
  }
}

class CardInfo extends StatefulWidget {
  const CardInfo({
    required this.tides,
    required this.currentTideID,
    Key? key,
  }) : super(key: key);
  final List<dynamic> tides;
  final int currentTideID;

  @override
  _CardInfoState createState() => _CardInfoState();
}

class _CardInfoState extends State<CardInfo> {
  @override
  Widget build(BuildContext context) {
    var tides = widget.tides;
    // Show nothing while loading.
    if (tides.isEmpty) {
      return const SizedBox.shrink();
    }

    var currentTideID = widget.currentTideID;
    var nextTides = tides.sublist(currentTideID, currentTideID + 20);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 15.0,
          child: Column(
            children: nextTides.map((dynamic tide) {
              var nextTime = DateTime.parse(tide["Time"]).toLocal();
              var day = nextTime.day;
              var dayPadding = day < 10 ? "0" : "";
              var month = nextTime.month;
              var monthPadding = month < 10 ? "0" : "";
              var year = nextTime.year;
              var minute = nextTime.minute;
              var hour = nextTime.hour;
              var hourPadding = hour < 10 ? "0" : "";
              var minutePadding = minute < 10 ? "0" : "";
              return ListTile(
                title: Text(
                    "$dayPadding$day/$monthPadding$month/$year $hourPadding$hour:$minutePadding$minute",
                    style: const TextStyle(
                      fontFeatures: [FontFeature.tabularFigures()],
                    )),
                trailing: Text(tide["Height"].toString() + "m"),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(
          top: 16.0,
          bottom: 16.0,
          left: 24.0,
        ),
        child: const Text(
          "* Powered by linz.govt.nz",
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ));
  }
}
