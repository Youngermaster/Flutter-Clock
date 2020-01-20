import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:intl/intl.dart';

void main() {
  if (!kIsWeb && Platform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  runApp(ClockCustomizer((ClockModel model) => FlutterClock(model)));
}

class FlutterClock extends StatefulWidget {
  final ClockModel model;
  const FlutterClock(this.model) : super();
  @override
  _FlutterClockState createState() => _FlutterClockState();
}

class _FlutterClockState extends State<FlutterClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  bool isSeparator = true;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(FlutterClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {});
  }

  void _updateTime() {
    setState(() {
      isSeparator = !isSeparator;
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final seconds = num.parse(DateFormat('ss').format(_dateTime));
    Widget h1 = Text(
      hour[0],
      style: Theme.of(context).textTheme.display4,
    );
    Widget h2 = Text(
      hour[1],
      style: Theme.of(context).textTheme.display4,
    );
    Widget m1 = Text(
      minute[0],
      style: Theme.of(context).textTheme.display4,
    );
    Widget m2 = Text(
      minute[1],
      style: Theme.of(context).textTheme.display4,
    );

    Widget separator = Text(
      ":",
      style: Theme.of(context).textTheme.display4,
    );

    Widget noSeparator = Text(
      " ",
      style: Theme.of(context).textTheme.display4,
    );

    double barWidth = MediaQuery.of(context).size.width * seconds / 60.0;
    return Column(children: <Widget>[
      Container(
        height: 4.0,
        width: barWidth,
        color: Colors.blueAccent,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          h1,
          h2,
          isSeparator ? separator : noSeparator,
          m1,
          m2
        ],
      ),
      Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Text(widget.model.temperatureString),
              Text(" - "),
              Text(widget.model.weatherString)
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Icon(Icons.location_on),
            VerticalDivider(width: 5.0,),
            Text(widget.model.location)
          ],
        ),
      )
    ]);
  }
}
