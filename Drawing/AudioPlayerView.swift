import SwiftUI
import CoreGraphics


public enum AudioPlayerState {
  case readyToPlay,
       loading,
       playing
}

let backgroundColor = Color.init(red: 229/255, green: 229/255, blue: 229/255)
let backgroundSecondaryColor = Color.init(red: 204/255, green: 204/255, blue: 206/255)
let primaryColor = Color.init(red: 2/255, green: 104/255, blue: 167/255)

public struct AudioPlayerView: View {
  //MARK:- Progresss between 0 and 1
  @Binding var progressInSeconds : Double
  @Binding var lenghtOfVideosInSeconds : Double
  @Binding var state : AudioPlayerState
  @State var displayForward : String
  @State var displayBackward : String
  var onTapPlay : (()->())?
  var onPause : (()->())?
  var onDarg : (()->())?
  
  public init(
    state : Binding<AudioPlayerState>,
    progressInSeconds : Binding<Double> ,
    lenghtOfVideosInSeconds :  Binding<Double>,
  onTapPlay : (()->())? = nil,
    onPause : (()->())? = nil,
    onDarg : (()->())? = nil
  ) {
    _state = state
    _progressInSeconds = progressInSeconds
    _lenghtOfVideosInSeconds = lenghtOfVideosInSeconds
    _displayForward = State(initialValue: AudioPlayerView.calDisplayForward(progressInSeconds.wrappedValue))
    _displayBackward = State(initialValue: AudioPlayerView.calDisplayBackward(progressInSeconds.wrappedValue,lenght: lenghtOfVideosInSeconds.wrappedValue))
    self.onTapPlay = onTapPlay
    self.onPause = onPause
    self.onDarg = onDarg
  }
  
  private static func fraction(_ s : Int) -> (Int,Int,Int) {
    return (s / 3600, (s % 3600) / 60, (s % 3600) % 60)
  }
  
  public static func calDisplayForward(_ s : Double) -> String {
    let (_, minutes,seconds) = fraction(Int(floor(s)))
    let k = String(format: "%01d:%02d", minutes,seconds)
    return k
  }
  
  public static func calDisplayBackward(_ s : Double,lenght : Double) -> String {
    let remainingSeconds = Int(floor(lenght - s))
    let (_, minutes,seconds) = fraction(remainingSeconds)
    return String(format: "%01d:%02d", minutes,seconds)
  }
  
  public var body: some View {
    GeometryReader {proxy in
      ZStack {
        Capsule().fill(backgroundColor)
        HStack(spacing: 2) {
          PlayPauseLoadingIcon(state: $state,onTapPlay: self.onTapPlay,onPause: self.onPause)
            .frame(width: min(proxy.size.width,proxy.size.height) ,
                   height: min(proxy.size.width,proxy.size.height))
          Text(displayForward).frame(width:50)
          VStack {
            AudioProgressBarSlider(value: $progressInSeconds, in: 0...Double(lenghtOfVideosInSeconds), step: 1,onDrag: self.onDarg)
              .onChange(of: progressInSeconds, perform: { newValue in
                self.displayForward = AudioPlayerView.calDisplayForward(newValue)
                self.displayBackward = AudioPlayerView.calDisplayBackward(newValue, lenght: lenghtOfVideosInSeconds)
              })
          }
          Text(displayBackward).frame(width:50)
          Spacer()
        }
      }
    }
  }
}

struct AudioPlayerView_Previews: PreviewProvider {
  static var previews: some View {
    AudioPlayerView.init(state: .constant(.playing), progressInSeconds: .constant(20), lenghtOfVideosInSeconds: .constant(60))
      .frame(height:55)
  }
}






