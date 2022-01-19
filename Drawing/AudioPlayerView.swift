import SwiftUI
import CoreGraphics


public enum AudioPlayerState {
  case readyToPlay,
       loading,
       pause
  
}

public struct AudioPlayerView: View {
  //MARK:- Progresss between 0 and 1
//  @State public var lenghtOfVideosInSeconds : Int = 60
  
  @Binding var progressInSeconds : Double
  var lenghtOfVideosInSeconds : Int
  @State var displayForward : String = ""
  @State var displayBackward : String = ""
  
  public init(progressInSeconds : Binding<Double> , lenghtOfVideosInSeconds :  Int) {
    _progressInSeconds = progressInSeconds
    self.lenghtOfVideosInSeconds = lenghtOfVideosInSeconds
  }
  
  private func fraction(_ s : Int) -> (Int,Int,Int) {
    return (s / 3600, (s % 3600) / 60, (s % 3600) % 60)
  }
  
  public func calDisplayForward(_ s : Double) -> String {
    let (_, minutes,seconds) = fraction(Int(floor(s)))
    return String(format: "%02d:%02d", minutes,seconds)
  }
  
  public func calDisplayBackward(_ s : Double) -> String {
    let remainingSeconds = Int(floor(Double(lenghtOfVideosInSeconds) - s))
    let (_, minutes,seconds) = fraction(remainingSeconds)
    return String(format: "%02d:%02d", minutes,seconds)
  }
  
  public var body: some View {
    GeometryReader {proxy in
      ZStack {
        Capsule().fill(Color.gray)
        HStack(spacing: 2) {
          PlayPauseLoadingIcon()
            .frame(width: min(proxy.size.width,proxy.size.height) ,
                   height: min(proxy.size.width,proxy.size.height))
          Text(displayForward).frame(width:50)
          VStack {
            AudioProgressBarSlider(value: $progressInSeconds, in: 0...Double(lenghtOfVideosInSeconds), step: 1)
              .onChange(of: progressInSeconds, perform: { newValue in
                self.displayForward = calDisplayForward(newValue)
                self.displayBackward = calDisplayBackward(newValue)
              })
              .background(Color.blue)
          }
          Text(displayBackward).frame(width:50)
          Spacer()
        }
      }
    }
  }
}

struct PlayPauseLoadingIcon : View {
  
  var body: some View {
    ZStack {
      CircleAudioPlayer()
        .fill(Color.black)
      Playicon()
        .fill(Color.blue)
        .onTapGesture {
          print("tap")
        }
    }
  }
  
}

struct CircleAudioPlayer: Shape {
  func path(in rect: CGRect) -> Path {
    var p = Path()
    let padding : CGFloat = 12
    let diameter = min(rect.width,rect.height) - padding
    
    p.addArc(
      center: CGPoint(x: padding / 2 + diameter / 2, y: diameter / 2 + padding / 2),
      radius: diameter / 2,
      startAngle: .degrees(0),
      endAngle: .degrees(360),
      clockwise: true)
    return p
  }
}

struct Playicon : Shape {
  
  func path(in rect: CGRect) -> Path {
    var p = Path()
    let min = min(rect.width,rect.height)
    let padding : CGFloat = min * 0.35
    let diameter = min - padding
    p.move(to: .init(x: padding, y: rect.minY + padding))
    p.addLine(to: .init(x: diameter, y: rect.midY))
    p.addLine(to: .init(x: padding, y: rect.maxY - padding))
    p.closeSubpath()
    return p
  }
  
}

struct AudioPlayerView_Previews: PreviewProvider {
  static var previews: some View {
    AudioPlayerView.init(progressInSeconds: .constant(20), lenghtOfVideosInSeconds: 60)
      .frame(height:55)
  }
}






