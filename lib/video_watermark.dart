// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/to/pubspec-plugin-platforms.


import 'package:video_watermark/watermark.dart';

import 'video_watermark_platform_interface.dart';

class VideoWatermark {
  static Future<String?> addWatermark({
    required String videoPath,
    required String watermarkPath,
    WatermarkPosition position = WatermarkPosition.bottomRight,
    WatermarkSize size = const WatermarkSize(100, 100),
    double opacity = 1.0,
  }) {
    return VideoWatermarkPlatform.instance.addWatermark(
      videoPath: videoPath,
      watermarkPath: watermarkPath,
      position: position,
      size: size,
      opacity: opacity,
    );
  }
}
