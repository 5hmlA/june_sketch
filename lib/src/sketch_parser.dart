import 'dart:ui';
import 'dart:math' as math;

class SketchPoints {
  final Offset start;
  final Offset control;
  final Offset end;

  SketchPoints(this.start, this.control, this.end);
}

double random(double orign, double offset) {
  if (offset == 0) {
    return orign;
  }
  offset *= 1000;
  if (offset > 0) {
    return orign + math.Random().nextInt(offset.toInt()) / 1000.0;
  }
  offset = -offset;
  return orign - math.Random().nextInt(offset.toInt()) / 1000.0;
}

class LineParse {
  Offset start = Offset.zero;
  Offset end = Offset.zero;
  Offset limit = Offset.zero;

  final double brushWidth;

  LineParse(this.brushWidth);

  update(Offset start, Offset end, Offset limit) {
    this.start = start;
    this.end = end;
    this.limit = limit;
  }

  @override
  List<SketchPoints> parse(List<SketchPoints> sketchPointsList) {
    print("parse > [$brushWidth] === ${this.hashCode} ");
    if ((start.dx - end.dx).abs() < 0.01) {
      return parseVerticalLine(sketchPointsList, brushWidth.toInt());
    }
    return parseLine(sketchPointsList, brushWidth.toInt());
  }

  List<SketchPoints> parseLine(
      List<SketchPoints> sketchPointsList, int brushWidth) {
    List<SketchPoints> pointsList = sketchPointsList;
    // y = k * x + b;
    double k = (end.dy - start.dy) / (end.dx - start.dx);
    double b = (end.dx * start.dy - start.dx * end.dy) / (end.dx - start.dx);
    double step = (end.dx - start.dx).abs() / 3;
    double startX = math.min(start.dx, end.dx);
    double endX = math.max(start.dx, end.dx);
    double nextX = start.dx;

    while (startX < endX) {
      nextX = math.min(startX + step * 2, endX + 1);
      double controlX = random(startX, nextX - startX);
      var dy = startX * k + b;
      // var dy = math.min(startX * k + b, limit.dy);
      pointsList.add(
        SketchPoints(
          Offset(startX, dy),
          Offset(
              controlX, controlX * k + b + math.Random().nextInt(brushWidth) + 1),
          Offset(nextX, nextX * k + b),
        ),
      );
      controlX = random(startX, nextX - startX);
      pointsList.add(
        SketchPoints(
          Offset(startX, dy),
          Offset(
              controlX, controlX * k + b - math.Random().nextInt(brushWidth) + 1),
          Offset(nextX, nextX * k + b),
        ),
      );
      startX += step;
    }
    return pointsList;
  }

  List<SketchPoints> parseVerticalLine(
      List<SketchPoints> sketchPointsList, int brushWidth) {
    List<SketchPoints> pointsList = sketchPointsList;
    double x = start.dx;
    double startY = math.min(start.dy, end.dy);
    double endY = math.max(start.dy, end.dy);
    double nextY = startY;
    double step = 10.0;
    while (startY < endY) {
      nextY = math.min(startY + step * 2, limit.dy);
      double controlY = random(startY, nextY - startY);
      pointsList.add(
        SketchPoints(
          Offset(x, startY),
          Offset(x + math.Random().nextInt(brushWidth) + 1, controlY),
          Offset(x, nextY),
        ),
      );
      controlY = random(startY, nextY - startY);
      pointsList.add(
        SketchPoints(
          Offset(x, startY),
          Offset(x - math.Random().nextInt(brushWidth) + 1, controlY),
          Offset(x, nextY),
        ),
      );
      startY += step;
    }
    return pointsList;
  }
}
