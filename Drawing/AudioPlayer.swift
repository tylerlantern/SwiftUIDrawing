import AVFoundation
import Foundation

public class AudioPlayer: NSObject {
    private var player = AVPlayer()
    private var asset: AVAsset!
    private var playerItem: AVPlayerItem!
    private var timeObserverToken: Any?
    private var onPlayingCurrentTime: ((Double) -> Void)?
    private var onPauseCurrentItem: (() -> Void)?
    private var audioPlayerFailState: ((AudioPlayerFailStates) -> Void)?
    private var onEndCurrentItem: (() -> Void)?
    private var readyToPlayWithDuration: ((Double) -> Void)?
    private var bufferedForPlay: (() -> Void)?
    private var playerItemContext = 0
    private let requiredAssetKeys = [
        "playable",
        "hasProtectedContent",
    ]

    @discardableResult
    public func onPlayingCurrentTime(_ closure: @escaping (Double) -> Void) -> AudioPlayer {
        onPlayingCurrentTime = closure
        return self
    }

    @discardableResult
    public func onPauseCurrentItem(_ closure: @escaping () -> Void) -> AudioPlayer {
        onPauseCurrentItem = closure
        return self
    }

    @discardableResult
    public func onEndCurrentItem(_ closure: @escaping () -> Void) -> AudioPlayer {
        onEndCurrentItem = closure
        return self
    }

    @discardableResult
    public func audioPlayerFailState(_ closure: @escaping (AudioPlayerFailStates) -> Void)
        -> AudioPlayer
    {
        audioPlayerFailState = closure
        return self
    }

    @discardableResult
    public func audioPlayerReadyToPlayWithDuration(_ closure: @escaping (Double) -> Void)
        -> AudioPlayer
    {
        readyToPlayWithDuration = closure
        return self
    }

    @discardableResult
    public func isAudioPlayerBuffered(_ closure: @escaping () -> Void) -> AudioPlayer {
        bufferedForPlay = closure
        return self
    }

    public func loadAudioUrl(audioURL: String, seconds: Double) {
        try! AVAudioSession.sharedInstance().setCategory(.playback)
        removePeriodicTimeObserver()
        guard let url = URL(string: audioURL) else { return }

        loadPlayerItem(url: url, atTimeInSeconds: seconds)

        handleAudioError()
        addPeriodicTimeObserver()
        addEndItemObserver()
    }

    public func setSeekToTimePlayer(seconds: Float64) {
        let cmTime = CMTimeMakeWithSeconds(seconds, preferredTimescale: 1000)
        player.seek(to: cmTime)
    }

    private func getAudioDuration() -> Double {
        Double(CMTimeGetSeconds(asset.duration))
    }

    public func pauseCurrentAudioItem(itemId _: Int?) {
        player.pause()
        onPauseCurrentItem?()
    }

    public func pauseAudio() {
        player.pause()
    }

    public func isAudioReadyToPlay() -> Bool {
        player.status.rawValue == 1
    }

    private func resetCurrentItem() {
        onEndCurrentItem?()
        player.pause()
        player.seek(to: CMTime.zero)
    }

    private func isCurrentPlayingUrl(url: URL) -> Bool {
        ((player.currentItem?.asset) as? AVURLAsset)?.url == url
    }

    private func isPlayingState() -> Bool {
        player.rate != 0 && player.error == nil
    }

    private func addEndItemObserver() {
        NotificationCenter.default
            .addObserver(
                forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main,
                using: { [weak self] _ in
                    self?.resetCurrentItem()
                }
            )
    }

    private func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        timeObserverToken = player
            .addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
                self?.onPlayingCurrentTime?(time.seconds)
                guard time.timescale == timeScale else { return }
                self?.bufferedForPlay?()
            }
    }

    private func removePeriodicTimeObserver() {
        if let currentTimeObserverToken = timeObserverToken {
            player.removeTimeObserver(currentTimeObserverToken)
            timeObserverToken = nil
        }
    }

    private func loadPlayerItem(url: URL, atTimeInSeconds seconds: Double?) {
        asset = AVAsset(url: url)
        playerItem = AVPlayerItem(
            asset: asset,
            automaticallyLoadedAssetKeys: requiredAssetKeys
        )
        playerItem.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayerItem.status),
            options: [.old, .new],
            context: &playerItemContext
        )
        player = AVPlayer(playerItem: playerItem)
//    self.player.play()
        if let chosenTime = seconds {
            player.seek(to: CMTimeMakeWithSeconds(chosenTime, preferredTimescale: 1000))
        }
    }

    public func play() {
        player.play()
    }

    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey: Any]?,
                                      context: UnsafeMutableRawPointer?)
    {
        guard context == &playerItemContext else {
            super.observeValue(
                forKeyPath: keyPath,
                of: object,
                change: change,
                context: context
            )
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            switch status {
            case .readyToPlay:
                self.readyToPlayWithDuration?(getAudioDuration())
            case .failed:
                self.handleAudioError()
            case .unknown:
                break
            default:
                break
            }
        }
    }

    private func handleAudioError() {
        if let error = playerItem?.error {
            error.code.description == AudioPlayerFailStates.connection.rawValue ?
                audioPlayerFailState?(.connection) :
                audioPlayerFailState?(.stream)
        }
    }
}

public enum AudioPlayerFailStates: String {
    case connection = "-1009"
    case stream = "-1102"
}

extension Error {
    var code: Int { (self as NSError).code }
    var domain: String { (self as NSError).domain }
}
