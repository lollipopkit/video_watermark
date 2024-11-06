// import 'package:flutter_test/flutter_test.dart';
// import 'package:video_watermark/video_watermark.dart';
// import 'package:video_watermark/video_watermark_platform_interface.dart';
// import 'package:video_watermark/video_watermark_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockVideoWatermarkPlatform
//     with MockPlatformInterfaceMixin
//     implements VideoWatermarkPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final VideoWatermarkPlatform initialPlatform = VideoWatermarkPlatform.instance;

//   test('$MethodChannelVideoWatermark is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelVideoWatermark>());
//   });

//   test('getPlatformVersion', () async {
//     VideoWatermark videoWatermarkPlugin = VideoWatermark();
//     MockVideoWatermarkPlatform fakePlatform = MockVideoWatermarkPlatform();
//     VideoWatermarkPlatform.instance = fakePlatform;

//     expect(await videoWatermarkPlugin.getPlatformVersion(), '42');
//   });
// }
