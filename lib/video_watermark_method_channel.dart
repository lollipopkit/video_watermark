import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:video_watermark/watermark.dart';

import 'video_watermark_platform_interface.dart';

/// An implementation of [VideoWatermarkPlatform] that uses method channels.
class MethodChannelVideoWatermark extends VideoWatermarkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cn.lpkt.video_watermark');

  @override
  /// 添加水印
  /// [videoPath] 视频文件路径
  /// [watermarkPath] 水印图片路径
  /// [position] 水印位置 
  /// [size] 水印大小
  Future<String?> addWatermark({
    required String videoPath,
    required String watermarkPath,
    WatermarkPosition position = WatermarkPosition.bottomRight,
    WatermarkSize size = const WatermarkSize(100, 100),
  }) async {
    try {
      final String? outputPath = await methodChannel.invokeMethod(
        'addWatermark',
        {
          'videoPath': videoPath,
          'watermarkPath': watermarkPath,
          'position': position.toJson(),
          'size': size.toJson(),
        },
      );
      return outputPath;
    } on PlatformException catch (e) {
      throw WatermarkException(e.message ?? 'Unknown error');
    }
  }
}
