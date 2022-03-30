import 'package:flutter/material.dart';
import 'package:luckydraw/luckydraw/luckydraw_wheel.dart';

class LuckyDrawPage extends StatelessWidget {
  const LuckyDrawPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
          child: Center(
              child: LuckyDrawWheel(
        width: MediaQuery.of(context).size.width,
      ))),
    );
  }
}
