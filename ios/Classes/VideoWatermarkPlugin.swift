import Flutter
import UIKit
import AVFoundation

public class VideoWatermarkPlusPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cn.lpkt.video_watermark", binaryMessenger: registrar.messenger())
        let instance = VideoWatermarkPlusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "addWatermark":
            guard let args = call.arguments as? [String: Any],
                  let videoPath = args["videoPath"] as? String,
                  let watermarkPath = args["watermarkPath"] as? String,
                  let position = args["position"] as? [String: Double],
                  let size = args["size"] as? [String: Double] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", 
                                  message: "Invalid parameters", 
                                  details: "Required parameters are missing or have invalid format"))
                return
            }
            
            // 验证文件是否存在
            guard FileManager.default.fileExists(atPath: videoPath),
                  FileManager.default.fileExists(atPath: watermarkPath) else {
                result(FlutterError(code: "FILE_NOT_FOUND",
                                  message: "Video or watermark file not found",
                                  details: nil))
                return
            }
            
            addWatermark(videoPath: videoPath,
                        watermarkPath: watermarkPath,
                        position: position,
                        size: size) { outputPath, error in
                if let error = error {
                    result(FlutterError(code: "PROCESSING_ERROR",
                                      message: error.localizedDescription,
                                      details: nil))
                } else {
                    result(outputPath)
                }
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func addWatermark(videoPath: String,
                             watermarkPath: String,
                             position: [String: Double],
                             size: [String: Double],
                             completion: @escaping (String?, Error?) -> Void) {
        // 创建视频资源
        let videoURL = URL(fileURLWithPath: videoPath)
        let asset = AVURLAsset(url: videoURL)
        
        // 确保视频资源可用
        guard asset.tracks(withMediaType: .video).first != nil else {
            completion(nil, NSError(domain: "VideoWatermark",
                                  code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "Invalid video file"]))
            return
        }
        
        // 创建可变合成
        let composition = AVMutableComposition()
        
        do {
            // 添加视频轨道
            guard let compositionTrack = composition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: kCMPersistentTrackID_Invalid),
                  let assetTrack = asset.tracks(withMediaType: .video).first else {
                throw NSError(domain: "VideoWatermark",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to create video track"])
            }
            
            // 添加音频轨道
            if let audioTrack = asset.tracks(withMediaType: .audio).first,
               let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid) {
                try compositionAudioTrack.insertTimeRange(
                    CMTimeRange(start: .zero, duration: asset.duration),
                    of: audioTrack,
                    at: .zero)
            }
            
            // 插入视频轨道
            try compositionTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: asset.duration),
                of: assetTrack,
                at: .zero)
            
            // 创建水印图层
            guard let watermarkImage = UIImage(contentsOfFile: watermarkPath) else {
                throw NSError(domain: "VideoWatermark",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to load watermark image"])
            }
            
            let parentLayer = CALayer()
            let videoLayer = CALayer()
            let watermarkLayer = CALayer()
            
            // 获取视频尺寸
            let videoSize = assetTrack.naturalSize
            parentLayer.frame = CGRect(origin: .zero, size: videoSize)
            videoLayer.frame = CGRect(origin: .zero, size: videoSize)
            
            // 设置水印位置和大小
            let watermarkWidth = CGFloat(size["width"] ?? 100)
            let watermarkHeight = CGFloat(size["height"] ?? 100)
            let x = videoSize.width * CGFloat(position["x"] ?? 0.8)
            let y = videoSize.height * CGFloat(position["y"] ?? 0.8)
            
            watermarkLayer.frame = CGRect(x: x,
                                        y: y,
                                        width: watermarkWidth,
                                        height: watermarkHeight)
            watermarkLayer.contents = watermarkImage.cgImage
            watermarkLayer.opacity = 0.8 // 设置水印透明度
            
            parentLayer.addSublayer(videoLayer)
            parentLayer.addSublayer(watermarkLayer)
            
            // 创建视频合成
            let videoComposition = AVMutableVideoComposition()
            videoComposition.renderSize = videoSize
            videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
                postProcessingAsVideoLayer: videoLayer,
                in: parentLayer)
            
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(
                assetTrack: compositionTrack)
            instruction.layerInstructions = [layerInstruction]
            videoComposition.instructions = [instruction]
            
            // 导出设置
            guard let exportSession = AVAssetExportSession(
                asset: composition,
                presetName: AVAssetExportPresetHighestQuality) else {
                throw NSError(domain: "VideoWatermark",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"])
            }
            
            // 创建输出路径
            let outputPath = NSTemporaryDirectory() + UUID().uuidString + ".mp4"
            let outputURL = URL(fileURLWithPath: outputPath)
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            exportSession.videoComposition = videoComposition
            
            // 执行导出
            exportSession.exportAsynchronously { [weak exportSession] in
                guard let exportSession = exportSession else {
                    completion(nil, NSError(domain: "VideoWatermark",
                                         code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Export session was deallocated"]))
                    return
                }
                
                DispatchQueue.main.async {
                    switch exportSession.status {
                    case .completed:
                        completion(outputPath, nil)
                    case .failed:
                        completion(nil, exportSession.error)
                    case .cancelled:
                        completion(nil, NSError(domain: "VideoWatermark",
                                             code: -1,
                                             userInfo: [NSLocalizedDescriptionKey: "Export was cancelled"]))
                    default:
                        completion(nil, NSError(domain: "VideoWatermark",
                                             code: -1,
                                             userInfo: [NSLocalizedDescriptionKey: "Export failed with unknown error"]))
                    }
                }
            }
            
        } catch {
            completion(nil, error)
        }
    }
}
