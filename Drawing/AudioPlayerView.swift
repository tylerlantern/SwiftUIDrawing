import SwiftUI
import CoreGraphics


public enum AudioPlayerState {
  case readyToPlay,
  loading,
  pause
  
}

public struct AudioPlayerView: View {
  @State public var progress : Double = 0
  @State public var lenghtOfVideosInSeconds : Int = 60
  
  private var progressInSeconds : Binding<Double> { Binding (
      get: { progress *  Double(lenghtOfVideosInSeconds) },
      set: { _ in  }
      )
  }
  
  public func displayCurrentProgress() {
    
  }
  
  public func displayRemainingTime() {
    
  }
  
 public var body: some View {
    GeometryReader {proxy in
      ZStack {
        Capsule().fill(Color.gray)
        HStack() {
          PlayPauseLoadingIcon()
            .frame(width: min(proxy.size.width,proxy.size.height) ,
                   height: min(proxy.size.width,proxy.size.height))
          Text("00:00")
          VStack {
            AudioProgressBarSlider(value: progressInSeconds, in: 0...Double(lenghtOfVideosInSeconds), step: 1)
            .background(Color.blue)
          }
          Text("00:00")
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
//    let center = CGPoint(x: padding / 2 + diameter / 2, y: diameter / 2 + padding / 2)
    p.move(to: .init(x: padding, y: rect.minY + padding))
    p.addLine(to: .init(x: diameter, y: rect.midY))
    p.addLine(to: .init(x: padding, y: rect.maxY - padding))
    p.closeSubpath()
    return p
  }
  
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
      AudioPlayerView.init()
        .frame(height:55)
    }
}






