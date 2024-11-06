class WatermarkPosition {
  final double x;
  final double y;

  const WatermarkPosition(this.x, this.y);

  static const bottomRight = WatermarkPosition(0.8, 0.8);
  static const topLeft = WatermarkPosition(0.2, 0.2);

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };
}

class WatermarkSize {
  final double width;
  final double height;

  const WatermarkSize(this.width, this.height);

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
      };
}
