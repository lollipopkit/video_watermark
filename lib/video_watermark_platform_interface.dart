import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:video_watermark/watermark.dart';

import 'video_watermark_method_channel.dart';

abstract class VideoWatermarkPlatform extends PlatformInterface {
  /// Constructs a VideoWatermarkPlatform.
  VideoWatermarkPlatform() : super(token: _token);

  static final Object _token = Object();

  static VideoWatermarkPlatform _instance = MethodChannelVideoWatermark();

  /// The default instance of [VideoWatermarkPlatform] to use.
  ///
  /// Defaults to [MethodChannelVideoWatermark].
  static VideoWatermarkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VideoWatermarkPlatform] when
  /// they register themselves.
  static set instance(VideoWatermarkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> addWatermark({
    required String videoPath,
    required String watermarkPath,
    WatermarkPosition position = WatermarkPosition.bottomRight,
    WatermarkSize size = const WatermarkSize(100, 100),
    double opacity = 1.0,
  }) {
    throw UnimplementedError('addWatermark() has not been implemented.');
  }
}
