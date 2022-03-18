import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:june_sketch/src/sketch_parser.dart';

@immutable
class SketchBorder extends BoxBorder {
  final BorderSide slide;
  final double dashWidth;

  final Paint _paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 2.0
    ..style = PaintingStyle.fill
    ..strokeJoin = StrokeJoin.round;

  final Path orignPath = Path();
  final Path sketchPath = Path();
  final List<SketchPoints> sketchPoints = [];

  SketchBorder({required this.slide}) : dashWidth = slide.width {
    _paint
      ..color = slide.color
      ..strokeWidth = 1.0;
  }

  @override
  BorderSide get top => slide;

  @override
  BorderSide get bottom => slide;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsetsDirectional.fromSTEB(
      bottom.width, top.width, bottom.width, bottom.width);

  @override
  bool get isUniform => true;

  @override
  void paint(Canvas canvas, Rect rect,
      {TextDirection? textDirection,
      BoxShape shape = BoxShape.rectangle,
      BorderRadius? borderRadius}) {
    orignPath.reset();
    sketchPath.reset();
    sketchPoints.clear();
    switch (shape) {
      case BoxShape.rectangle:
        if (borderRadius != null) {
          orignPath.addRRect(borderRadius.toRRect(rect));
        } else {
          orignPath.addRect(rect);
        }
        break;
      case BoxShape.circle:
        orignPath.addOval(rect);
        break;
    }
    PathMetrics pathMetrics = orignPath.computeMetrics();
    // y = .02 + 2
    //100 4   300 8
    double dashWidth = this.dashWidth;
    if (dashWidth == 1) {
      var def = rect.longestSide * .02 + 2;
      dashWidth = def;
    }
    dashWidth = math.max(dashWidth, 3);
    double distance = 0.0;
    Offset? start;
    Offset? middle;

    LineParse line = LineParse(dashWidth);
    while (pathMetrics.iterator.moveNext()) {
      PathMetric pathMetric = pathMetrics.iterator.current;
      while (distance < pathMetric.length) {
        var extractPath =
            pathMetric.extractPath(distance, distance += dashWidth);
        Rect bound = extractPath.getBounds();

        distance += dashWidth;
        // canvas.drawRect(bound, _paint2..style = PaintingStyle.stroke);
        // canvas.drawCircle(bound.center, 1, _paint..style = PaintingStyle.fill);
        Offset next = bound.center;
        if (middle == null && start == null) {
          start = next;
          continue;
        }
        if (middle == null) {
          middle = next;
        } else {
          line.update(start!, next, rect.bottomRight);
          line.parse(sketchPoints);
          start = middle;
          middle = next;
        }
      }
    }

    for (var element in sketchPoints) {
      sketchPath.moveTo(element.start.dx, element.start.dy);
      sketchPath.quadraticBezierTo(element.control.dx, element.control.dy,
          element.end.dx, element.end.dy);
    }
    canvas.drawPath(sketchPath, _paint);
  }

  @override
  ShapeBorder scale(double t) => SketchBorder(slide: top.scale(t));
}
