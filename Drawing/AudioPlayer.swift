import AVFoundation
import Foundation

public class AudioPlayer: NSObject {
  private var player = AVPlayer()
  private var asset: AVAsset!
  private var playerItem: AVPlayerItem!
  private var timeObserverToken: Any?
  private var onPlayingCurrentTime: ((Double) -> ())?
  private var onPauseCurrentItem: (() -> ())?
  private var audioPlayerFailState: ((AudioPlayerFailStates) -> ())?
  private var onEndCurrentItem: (() -> ())?
  private var readyToPlayWithDuration: ((Double) -> ())?
  private var bufferedForPlay: (() -> ())?
  private var playerItemContext = 0
  private let requiredAssetKeys = [
    "playable",
    "hasProtectedContent"
  ]
  
  @discardableResult
  public func onPlayingCurrentTime(_ closure: @escaping (Double) -> ()) -> AudioPlayer {
    self.onPlayingCurrentTime = closure
    return self
  }
  
  @discardableResult
  public func onPauseCurrentItem(_ closure: @escaping () -> ()) -> AudioPlayer {
    self.onPauseCurrentItem = closure
    return self
  }
  
  @discardableResult
  public func onEndCurrentItem(_ closure: @escaping () -> ()) -> AudioPlayer {
    self.onEndCurrentItem = closure
    return self
  }
  
  @discardableResult
  public func audioPlayerFailState(_ closure: @escaping (AudioPlayerFailStates) -> ())
  -> AudioPlayer
  {
    self.audioPlayerFailState = closure
    return self
  }
  
  @discardableResult
  public func audioPlayerReadyToPlayWithDuration(_ closure: @escaping (Double) -> ())
  -> AudioPlayer
  {
    self.readyToPlayWithDuration = closure
    return self
  }
  
  @discardableResult
  public func isAudioPlayerBuffered(_ closure: @escaping () -> ()) -> AudioPlayer {
    self.bufferedForPlay = closure
    return self
  }
  
  public func loadAudioUrl(audioURL: String, itemId: Int, seconds: Double) {
    try! AVAudioSession.sharedInstance().setCategory(.playback)
    self.removePeriodicTimeObserver()
    guard let url = URL(string: audioURL) else { return }
    
    self.loadPlayerItem(url: url, atTimeInSeconds: seconds)
    
    self.handleAudioError()
    self.addPeriodicTimeObserver()
    self.addEndItemObserver()
  }
  
  public func setSeekToTimePlayer(seconds: Float64, itemId: Int) {
    let cmTime = CMTimeMakeWithSeconds(seconds, preferredTimescale: 1_000)
    player.seek(to: cmTime)

  }
  
  
  private func getAudioDuration() -> Double {
    Double(CMTimeGetSeconds(self.asset.duration))
  }
  
  public func pauseCurrentAudioItem(itemId: Int?) {
      self.player.pause()
      self.onPauseCurrentItem?()
  }
  
  public func pauseAudio() {
    self.player.pause()
  }
  
  public func isAudioReadyToPlay() -> Bool {
    self.player.status.rawValue == 1
  }
  
  private func resetCurrentItem() {
    self.onEndCurrentItem?()
    self.player.pause()
    self.player.seek(to: CMTime.zero)
  }
  
  private func isCurrentPlayingUrl(url: URL) -> Bool {
    ((self.player.currentItem?.asset) as? AVURLAsset)?.url == url
  }
  
  private func isPlayingState() -> Bool {
    self.player.rate != 0 && self.player.error == nil
  }
  
  private func addEndItemObserver() {
    NotificationCenter.default
      .addObserver(
        forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
        object: self.player.currentItem,
        queue: .main,
        using: { [weak self] _ in
          self?.resetCurrentItem()
        }
      )
  }
  
  private func addPeriodicTimeObserver() {
    let timeScale = CMTimeScale(NSEC_PER_SEC)
    let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
    timeObserverToken = self.player
      .addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
        self?.onPlayingCurrentTime?(time.seconds)
        guard time.timescale == timeScale else { return }
        self?.bufferedForPlay?()
      }
  }
  
  private func removePeriodicTimeObserver() {
    if let currentTimeObserverToken = timeObserverToken {
      self.player.removeTimeObserver(currentTimeObserverToken)
      self.timeObserverToken = nil
    }
  }
  
  private func loadPlayerItem(url: URL, atTimeInSeconds seconds: Double?) {
    self.asset = AVAsset(url: url)
    self.playerItem = AVPlayerItem(
      asset: self.asset,
      automaticallyLoadedAssetKeys: self.requiredAssetKeys
    )
    self.playerItem.addObserver(
      self,
      forKeyPath: #keyPath(AVPlayerItem.status),
      options: [.old, .new],
      context: &self.playerItemContext
    )
    self.player = AVPlayer(playerItem: self.playerItem)
    self.player.play()
    if let chosenTime = seconds {
      self.player.seek(to: CMTimeMakeWithSeconds(chosenTime, preferredTimescale: 1_000))
    }
  }
  
  override public func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey: Any]?,
                                    context: UnsafeMutableRawPointer?)
  {
    guard context == &self.playerItemContext else {
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
    if let error = self.playerItem?.error {
      error.code.description == AudioPlayerFailStates.connection.rawValue ?
      self.audioPlayerFailState?(.connection) :
      self.audioPlayerFailState?(.stream)
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
