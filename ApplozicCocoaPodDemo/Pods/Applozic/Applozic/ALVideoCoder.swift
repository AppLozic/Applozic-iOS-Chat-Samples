//
//  ALVideoCoder.swift
//  Pods
//
//  Created by Sander on 9/29/18.
//

import Foundation
import Photos

private struct ProgressItem {
    var convertProgress: Progress
    var trimProgress: Progress
    var durationSeconds: TimeInterval
    var exportSession: AVAssetExportSession
}

protocol AssetSource {
    var durationSeconds: Int { get }
    func getAVAsset(_ handler: @escaping (AVAsset?) -> Void)
}

extension PHAsset: AssetSource {
    
    var durationSeconds: Int {
        return Int(duration)
    }
    
    func getAVAsset(_ handler: @escaping (AVAsset?) -> Void) {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .mediumQualityFormat
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestAVAsset(forVideo: self, options: options) { (asset, audioMix, info) in
            DispatchQueue.main.async {
                handler(asset)
            }
        }
    }
}
extension AVAsset: AssetSource {
    
     var durationSeconds: Int {
        return Int(CMTimeGetSeconds(duration))
    }
    func getAVAsset(_ handler: @escaping (AVAsset?) -> Void) {
        handler(self)
    }
}

@objc public class ALVideoCoder: NSObject {
    
    private let koef = 100.0
    // EXPORT PROGRESS VALUES
    private var exportingVideoSessions = [AVAssetWriter]()
    private var progressItems = [ProgressItem]()
    private var mainProgress: Progress?
    private var exportSessionMainProgress: Progress?
    private var alertVC: UIViewController?
    private var timer: Timer?
    
    @objc public func convert(phAssets: [PHAsset], range: CMTimeRange, baseVC: UIViewController, completion: @escaping ([String]?) -> Void) {
        convert(videoAssets: phAssets, range: range, baseVC: baseVC, completion: completion)
    }
    
    @objc public func convert(avAssets: [AVURLAsset], range: CMTimeRange, baseVC: UIViewController, completion: @escaping ([String]?) -> Void) {
        convert(videoAssets: avAssets, range: range, baseVC: baseVC, completion: completion)
    }
    
    private func convert(videoAssets: [AssetSource], range: CMTimeRange, baseVC: UIViewController, completion: @escaping ([String]?) -> Void) {
        
        let exportVideo = { [weak self] in
            self?.exportMultipleVideos(videoAssets, range: range, exportStarted: { [weak self] in
                self?.showProgressAlert(on: baseVC)
            }, completion: { [weak vc = baseVC] paths in
                
                if paths != nil {
                    // preventing crash for short video, with the controller that would attempt to dismiss while being presented
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
                        vc?.dismiss(animated: true)
                    }
                }
                completion(paths)
            })
        }
        
        if ALApplozicSettings.is5MinVideoLimitInGalleryEnabled(), videoAssets.first(where: { $0.durationSeconds > 300 }) != nil {
            
            let message = NSLocalizedString("videoWarning", value: "The video you’re attempting to send exceeds the 5 minutes limit. If you proceed, only a 5 minutes of the video will be selected and the rest will be trimmed out.", comment: "")
            
            let alertView = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title:NSLocalizedString("okText", value: "OK", comment: ""), style: .default, handler: { _ in
                exportVideo()
            }))
            alertView.addAction(UIAlertAction(title: NSLocalizedString("cancelOptionText", value: "Cancel", comment: ""), style: .cancel, handler: { _ in
                completion(nil)
            }))
            baseVC.present(alertView, animated: true)
        } else {
            exportVideo()
        }
    }
}

// MARK: PRIVATE API
extension ALVideoCoder {
    
    private func showProgressAlert(on vc: UIViewController) {
        let alertView = UIAlertController(title: NSLocalizedString("optimizingText", value: "Optimizing...", comment: ""), message: " ", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title:  NSLocalizedString("cancelOptionText", value: "Cancel", comment: ""), style: .cancel, handler: { [weak self] _ in
            self?.exportingVideoSessions.forEach { $0.cancelWriting() }
            self?.progressItems.forEach { $0.exportSession.cancelExport() }
            DispatchQueue.main.asyncAfter(deadline:.now() + .milliseconds(400), execute: {
                self?.exportingVideoSessions.removeAll()
                self?.progressItems.removeAll()
                self?.timer?.invalidate()
            })
        }))
        var mainProgress: Progress?
        if #available(iOS 9.0, *) {
            
            let totalDuration = progressItems.reduce(0) { $0 + $1.durationSeconds }
            mainProgress = Progress(totalUnitCount: Int64(totalDuration * koef))
            
            for item in progressItems {
                mainProgress?.addChild(item.convertProgress, withPendingUnitCount: Int64(item.durationSeconds*koef*0.85))
                mainProgress?.addChild(item.trimProgress, withPendingUnitCount: Int64(item.durationSeconds*koef*0.15))
            }
            self.mainProgress = mainProgress
        }
        
        vc.present(alertView, animated: true, completion: {
            if #available(iOS 9.0, *) {
                let margin: CGFloat = 8.0
                let rect = CGRect(x: margin, y: 62.0, width: alertView.view.frame.width - margin * 2.0, height: 2.0)
                let progressView = UIProgressView(frame: rect)
                progressView.observedProgress = mainProgress
                progressView.tintColor = UIColor.blue
                alertView.view.addSubview(progressView)
            }
        })
    }
    
    private func exportMultipleVideos(_ assets: [AssetSource], range: CMTimeRange, exportStarted: @escaping () -> Void, completion: @escaping ([String]?) -> Void) {
        
        guard !assets.isEmpty else {
            completion([])
            return
        }
        
        let dispatchExportStartedGroup = DispatchGroup()
        let dispatchExportCompletedGroup = DispatchGroup()
        
        var videoPaths: [String] = []
        for video in assets {
            
            dispatchExportStartedGroup.enter()
            dispatchExportCompletedGroup.enter()
            exportVideoAsset(video, range: range, exportStarted: dispatchExportStartedGroup.leave(), completion: { path in
                if let videoPath = path {
                    videoPaths.append(videoPath)
                }
                dispatchExportCompletedGroup.leave()
            })
        }
        
        dispatchExportStartedGroup.notify(queue: .main, execute: exportStarted)
        dispatchExportCompletedGroup.notify(queue: .main) {
            completion(videoPaths.isEmpty ? nil : videoPaths)
        }
    }
    
    private func exportVideoAsset(_ asset: AssetSource, range: CMTimeRange, exportStarted: @autoclosure @escaping () -> Void, completion: @escaping (String?) -> Void) {
        
        asset.getAVAsset { [weak self] (asset) in
            guard let urlAsset = asset as? AVURLAsset, let strongSelf = self else {
                exportStarted()
                completion(nil)
                return
            }
            
            var currentDuration = CMTimeGetSeconds(urlAsset.duration)
            let requestedDuration = CMTimeGetSeconds(range.duration)

            if currentDuration > requestedDuration {
                currentDuration = requestedDuration
            }
            
            let fileManager = FileManager.default
            let filename = String(format: "VIDTrim-%f.mp4", Date().timeIntervalSince1970*1000)
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let filePath = documentsUrl.absoluteString.appending(filename)
            
            let trimmedURL = URL(string: filePath)!
            
            // Remove existing file
            try? fileManager.removeItem(at: trimmedURL)
            
            let convertProgress = Progress(totalUnitCount: Int64(currentDuration * Double(strongSelf.koef)))
            let session = strongSelf.trimVideo(videoAsset: urlAsset, range: range, atURL: trimmedURL) { trimmedAsset in
                
                guard let newAsset = trimmedAsset else {
                    completion(nil)
                    return
                }
                
                let filename = String(format: "VID-%f.mp4", Date().timeIntervalSince1970*1000)
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let filePath = documentsUrl.absoluteString.appending(filename)
                
                guard var fileurl = URL(string: filePath) else {
                    completion(nil)
                    return
                }
                fileurl = fileurl.standardizedFileURL
                
                // remove any existing file at that location
                try? FileManager.default.removeItem(at: fileurl)
                
                ALVideoCoder.convertVideoToLowQuailtyWithInputURL(videoAsset: newAsset, outputURL: fileurl, progress: convertProgress, started: { writer in
                    self?.exportingVideoSessions.append(writer)
                }, completed: {
                    completion(fileurl.path)
                    try? fileManager.removeItem(at: trimmedURL)
                })
            }
            
            let trimProgress = Progress(totalUnitCount: Int64(currentDuration * Double(strongSelf.koef)))
            
            self?.progressItems.append(ProgressItem(convertProgress: convertProgress, trimProgress: trimProgress, durationSeconds: currentDuration, exportSession: session))
            
            exportStarted()
            if self?.timer == nil {
                self?.timer = Timer.scheduledTimer(timeInterval: 0.3, target: strongSelf, selector: #selector(strongSelf.update), userInfo: nil, repeats: true)
            }
        }
    }
    
    // video processing
    private func trimVideo(videoAsset: AVURLAsset, range: CMTimeRange, atURL:URL, completed: @escaping (AVURLAsset?) -> Void) -> AVAssetExportSession {

        let exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetPassthrough)!
        exportSession.outputURL = atURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.timeRange = range
        exportSession.exportAsynchronously {
            switch(exportSession.status) {
            case .completed:
                completed(AVURLAsset(url: atURL))
                self.timer?.invalidate()
            case .failed, .cancelled:
                completed(nil)
                self.timer?.invalidate()
            default: break
            }
        }
        return exportSession
    }
    
    @objc func update() {
        for item in progressItems {
            let trimProgress = Int64(Double(item.exportSession.progress) * koef * item.durationSeconds)
            item.trimProgress.completedUnitCount = trimProgress
        }
    }
    
    private class func convertVideoToLowQuailtyWithInputURL(videoAsset: AVURLAsset, outputURL: URL, progress: Progress, started: (AVAssetWriter) -> Void, completed: @escaping () -> Void) {
        
        //setup video writer
        let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let videoSize = videoTrack.naturalSize
        
        let widthIsBigger = max(videoSize.height, videoSize.width) == videoSize.width
        let ratio = (widthIsBigger ? videoSize.height : videoSize.width) / 480.0
        
        let videoWriterCompressionSettings = [
            AVVideoAverageBitRateKey : 815_000
        ]
        
        let videoWriterSettings:[String : Any] = [
            AVVideoCodecKey : AVVideoCodecH264,
            AVVideoCompressionPropertiesKey : videoWriterCompressionSettings,
            AVVideoWidthKey : Int(videoSize.width/ratio),
            AVVideoHeightKey : Int(videoSize.height/ratio)
        ]
        
        let videoWriter = try! AVAssetWriter(outputURL: outputURL, fileType: .mov)
        
        let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoWriterSettings)
        videoWriterInput.expectsMediaDataInRealTime = true
        videoWriterInput.transform = videoTrack.preferredTransform
        videoWriter.add(videoWriterInput)
        //setup video reader
        let videoReaderSettings:[String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
        ]
        
        let videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        let videoReader = try! AVAssetReader(asset: videoAsset)
        videoReader.add(videoReaderOutput)
        //setup audio writer
        let audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
        audioWriterInput.expectsMediaDataInRealTime = false
        videoWriter.add(audioWriterInput)
        //setup audio reader
        let audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio)[0]
        let audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        let audioReader = try! AVAssetReader(asset: videoAsset)
        audioReader.add(audioReaderOutput)
        videoWriter.startWriting()
        
        //start writing from video reader
        videoReader.startReading()
        videoWriter.startSession(atSourceTime: .zero)
        let processingQueue = DispatchQueue(label: "processingQueue1")
        videoWriterInput.requestMediaDataWhenReady(on: processingQueue) {
            while videoWriterInput.isReadyForMoreMediaData {
                
                if let sampleBuffer = videoReaderOutput.copyNextSampleBuffer(), videoReader.status == .reading {
                    videoWriterInput.append(sampleBuffer)
                    let timeStamp = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
                    progress.completedUnitCount = Int64(timeStamp*100)
                } else {
                    videoWriterInput.markAsFinished()
                    if videoReader.status == .completed {
                        //start writing from audio reader
                        audioReader.startReading()
                        videoWriter.startSession(atSourceTime: .zero)
                        let processingQueue = DispatchQueue(label: "processingQueue2")
                        audioWriterInput.requestMediaDataWhenReady(on: processingQueue) {
                            while audioWriterInput.isReadyForMoreMediaData {
                                
                                if let sampleBuffer = audioReaderOutput.copyNextSampleBuffer(), audioReader.status == .reading {
                                    audioWriterInput.append(sampleBuffer)
                                } else {
                                    audioWriterInput.markAsFinished()
                                    if audioReader.status == .completed {
                                        videoWriter.finishWriting {
                                            completed()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        started(videoWriter)
    }
}
