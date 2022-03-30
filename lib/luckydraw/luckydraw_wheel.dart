import 'dart:math';

import 'package:flutter/material.dart';

Color randomColor() {
  return Color.fromRGBO(Random().nextInt(255), Random().nextInt(255),
      Random().nextInt(255), Random().nextDouble());
}

const totalRadian = 3.14 * 2;
final colors = [
  Colors.yellow,
  Colors.amber,
  Colors.purple,
  Colors.indigoAccent,
  Colors.white,
  Colors.deepOrange,
  Colors.lightGreen,
];

class LuckyDrawWheel extends StatefulWidget {
  final double width;

  const LuckyDrawWheel({
    Key? key,
    required this.width,
  }) : super(key: key);

  @override
  State<LuckyDrawWheel> createState() => _LuckyDrawWheelState();
}

enum LuckyDrawstate {
  intimer,
  canwatchads,
  candraw,
}

class _LuckyDrawWheelState extends State<LuckyDrawWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int curItem = 0;
  late final double width;
  // Timer
  final texts = [
    "a",
    "b",
    "c",
    "d",
    "e",
  ];
  late final List<LuckyDrawTile> a;
  @override
  void initState() {
    width = widget.width;
    a = [
      ...texts.map((element) {
        return LuckyDrawTile(
          color: randomColor(),
          percentage: 1 / texts.length,
          text: element,
        );
      })
    ];
    curItem = Random().nextInt(a.length);
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10));

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("Landed on " + texts.elementAt(curItem)),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Play Again"),
                ),
              ],
            );
          },
        );
        setState(() {
          _controller.reset();
          curItem = Random().nextInt(a.length);
        });
        print(curItem);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(),
      child: SizedBox(
        width: width,
        height: width,
        child: Stack(
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return SizedBox(
                    width: width - width / 10,
                    height: width - width / 10,
                    child: CustomPaint(
                      painter: LuckyWheelPainter(
                        tiles: a
                        // const [
                        //   LuckyDrawTile(
                        //     color: Colors.blue,
                        //     percentage: 0.1,
                        //     text: "a",
                        //   ),
                        //   LuckyDrawTile(
                        //     color: Colors.green,
                        //     percentage: 0.3,
                        //     text: "b",
                        //   ),
                        //   LuckyDrawTile(
                        //     color: Colors.red,
                        //     percentage: 0.2,
                        //     text: "c",
                        //   ),
                        //   LuckyDrawTile(
                        //     color: Colors.amber,
                        //     percentage: 0.4,
                        //     text: "d",
                        //   ),
                        // ]
                        ,
                        rotate: Curves.easeInOut.transform(_controller.value) *
                            totalRadian *
                            20,
                        currentItem: curItem,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.asset("images/wheel.png").image,
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    scale: (6 - (width / 100)).clamp(1, 5),
                    image: Image.asset("images/wheel_button.png").image,
                  ),
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _controller.forward();
                    },
                    child: const Text(
                      "Draw",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LuckyWheelPainter extends CustomPainter {
  int currentItem = 0;
  double rotate = 0.0;
  final double outlineWidth = 20;
  final List<LuckyDrawTile> tiles = [];

  LuckyWheelPainter({
    this.rotate = 0,
    this.currentItem = 0,
    required List<LuckyDrawTile> tiles,
  }) {
    double lastPercentage = 0;
    for (var i in tiles) {
      lastPercentage += i.percentage;
      this.tiles.add(i.copyWith(percentage: lastPercentage));
    }
    assert(lastPercentage.round() == 1, "total percentages should be 1");
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radian = (totalRadian * tiles.elementAt(currentItem).percentage);
    final radian2 = currentItem + 1 == tiles.length
        ? (totalRadian * tiles.elementAt(0).percentage) + totalRadian
        : (totalRadian * tiles.elementAt(currentItem + 1).percentage);

    canvas.clipRRect(
      RRect.fromRectAndRadius(
        const Offset(0, 0) & Size(size.width, size.height),
        const Radius.circular(9999),
      ),
    );

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotate);

    canvas.rotate(-totalRadian / 4);
    if (rotate >= totalRadian) {
      canvas.rotate(-(radian + radian2) / 2);
    }
    canvas.translate(-size.width / 2, -size.height / 2);

    for (var i = 0; i < tiles.length; i++) {
      final radian = (totalRadian * tiles.elementAt(i).percentage);
      final radian2 = i + 1 == tiles.length
          ? (totalRadian * tiles.elementAt(0).percentage) + totalRadian
          : (totalRadian * tiles.elementAt(i + 1).percentage);

      // canvas.drawLine(
      //   Offset(size.width / 2, size.height / 2),
      //   Offset.fromDirection(radian, size.width * 10000),
      //   Paint()
      //     ..color = Colors.red
      //     ..strokeWidth = 5,
      // );
      final a = Offset.fromDirection(radian, size.width * 10000);
      final b = Offset.fromDirection(radian2, size.width * 10000);

      canvas.drawPath(
        Path()
          ..moveTo(size.width / 2, size.height / 2)
          ..lineTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..lineTo(size.width / 2, size.height / 2),
        Paint()..color = tiles.elementAt(i).color,
      );
      canvas.save();
      final textSpan = TextSpan(
        text: tiles.elementAt(i).text,
        style: tiles.elementAt(i).textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        maxLines: 3,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width / 4,
      );

      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(radian);
      canvas.rotate((radian2 - radian) / 2);
      canvas.translate(-size.width / 2, -size.height / 2);
      canvas.translate(size.width / 2 - textPainter.width / 2,
          size.height / 2 - textPainter.height / 2);
      textPainter.paint(
        canvas,
        Offset.fromDirection(0, size.width / 4),
      );
      canvas.translate(-(size.width / 2 - textPainter.width / 2),
          -(size.height / 2 - textPainter.height / 2));

      canvas.restore();
    }

    canvas.restore();
    // canvas.drawPath(
    //     Path()
    //       ..moveTo(size.width / 2 - 12, size.height / 2)
    //       ..lineTo(size.width / 2 + 12, size.height / 2)
    //       ..lineTo(
    //         size.width / 2,
    //         size.height / 2 - 50,
    //       )
    //       ..lineTo(
    //         size.width / 2 - 12,
    //         size.height / 2,
    //       ),
    //     Paint()..color = Colors.black);
    // canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 10,
    //     Paint()..color = Colors.white);
    // canvas.drawCircle(
    //   Offset(size.width / 2, size.height / 2),
    //   size.width / 10,
    //   Paint()
    //     ..color = Colors.black
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = 2.5,
    // );
    // canvas.drawCircle(
    //   Offset(
    //     size.width / 2,
    //     size.height / 2,
    //   ),
    //   size.width / 2,
    //   Paint()
    //     ..color = Colors.transparent
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = outlineWidth,
    // );
    // for (var i = 0; i < tiles.length; i++) {
    //   final radian = (totalRadian * tiles.elementAt(i).percentage);
    //   final radian2 = i + 1 == tiles.length
    //       ? (totalRadian * tiles.elementAt(0).percentage) + totalRadian
    //       : (totalRadian * tiles.elementAt(i + 1).percentage);

    //   canvas.save();
    //   canvas.translate(size.width / 2, size.height / 2);
    //   canvas.rotate(rotate);

    //   canvas.rotate(-totalRadian / 4);
    //   if (rotate >= totalRadian) {
    //     canvas.rotate(-(radian + radian2) / 2);
    //   }
    //   canvas.translate(-size.width / 2, -size.height / 2);
    //   canvas.translate(size.width / 2, size.height / 2);
    //   canvas.drawCircle(
    //     Offset.fromDirection(radian, (size.width / 2) - outlineWidth / 4),
    //     5,
    //     Paint()..color = Colors.red,
    //   );
    //   canvas.translate(-size.width / 2, -size.height / 2);
    //   canvas.restore();
    // }
  }

  Path getTrianglePath(double baseWidth, double pointDistance, Size size) {
    return Path()
      ..moveTo(size.width / 2 - baseWidth, 0)
      ..lineTo(size.width / 2 + baseWidth, 0)
      ..lineTo(size.width / 2, pointDistance)
      ..lineTo(size.width / 2 - baseWidth, 0);
  }

  @override
  bool shouldRepaint(covariant LuckyWheelPainter oldDelegate) {
    return true;
  }
}

class LuckyDrawTile {
  final Color color;
  final double percentage;
  final String text;
  final TextStyle textStyle;

  const LuckyDrawTile({
    this.color = Colors.blue,
    required this.text,
    required this.percentage,
    this.textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 18,
    ),
  });

  LuckyDrawTile copyWith({
    Color? color,
    double? percentage,
    String? text,
    TextStyle? textStyle,
  }) {
    return LuckyDrawTile(
      text: text ?? this.text,
      percentage: percentage ?? this.percentage,
      color: color ?? this.color,
      textStyle: textStyle ?? this.textStyle,
    );
  }
}
