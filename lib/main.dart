import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luckydraw/luckydraw/luckydraw_page.dart';
import 'package:luckydraw/luckydraw/luckydraw_wheel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const LuckyDrawPage(),
    );
  }
}

enum LuckyDrawstate {
  intimer,
  canwatchads,
  candraw,
}

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  // final db = SharedPreferences.getInstance();
  LuckyDrawstate state = LuckyDrawstate.intimer;
  late Timer timer;
  int time = 0;
  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      time = value.getInt("ads_time") ?? 0;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (time < DateTime.now().millisecondsSinceEpoch / 1000) {
        if (state == LuckyDrawstate.intimer) {
          state = LuckyDrawstate.canwatchads;
        }
      } else {
        state = LuckyDrawstate.intimer;
      }
      setState(() {});
    });
    super.initState();
  }

  void draw() {
    print("draw finished");
    state = LuckyDrawstate.intimer;
    time = ((DateTime.now().millisecondsSinceEpoch / 1000 +
            const Duration(minutes: 1).inSeconds))
        .round();
    SharedPreferences.getInstance().then((value) {
      value.setInt("ads_time", time);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = time - (DateTime.now().millisecondsSinceEpoch / 1000).ceil();
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Text("${state == LuckyDrawstate.intimer ? t : state.toString()} s"),
          ElevatedButton(
              onPressed: () {
                print("watched ads");
                state = LuckyDrawstate.candraw;
                setState(() {});
              },
              child: const Text("Watch Ads")),
          ElevatedButton(
              onPressed: () {
                if (state == LuckyDrawstate.candraw) {
                  print("draw");
                  draw();
                }
              },
              child: const Text("Draw")),
        ],
      )),
    );
  }
}
