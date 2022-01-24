import SwiftUI

struct PlayPauseLoadingIcon : View {
  
  @Binding var state : AudioPlayerState
  var onTapPlay : (()->())?
  var onPause : (()->())?
  
  var body: some View {
    ZStack {
      CircleAudioPlayer()
        .fill(primaryColor)
      switch state {
      case .readyToPlay :
        Playicon()
          .fill(backgroundColor)
          .onTapGesture {
            onTapPlay?()
          }
      case .playing :
        PauseIcon()
          .stroke(backgroundColor,lineWidth:  5)
          .onTapGesture {
            state = .readyToPlay
            onPause?()
          }
      case .loading:
        ProgressView().tint(Color.gray)
      }
    }
//    .background(Color.black)
  }
}

struct CircleAudioPlayer: Shape {
  func path(in rect: CGRect) -> Path {
    var p = Path()
    let diameter = min(rect.width,rect.height)
    let padding = diameter * 0.08
    p.addArc(
      center: CGPoint(x: diameter / 2, y: diameter / 2),
      radius: diameter / 2 - padding,
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
    let padding : CGFloat = min * 0.36
    let diameter = min - padding
    p.move(to: .init(x: padding, y: rect.minY + padding))
    p.addLine(to: .init(x: diameter, y: rect.midY))
    p.addLine(to: .init(x: padding, y: rect.maxY - padding))
    p.closeSubpath()
    return p
  }
}

struct PauseIcon : Shape {
  func path(in rect: CGRect) -> Path {
    var p = Path()
    let diameter = min(rect.width,rect.height)
    
    let topLeft = CGPoint.init(x: diameter * 0.40, y: diameter / 2 - diameter * 0.16)
    let bottomLeft = CGPoint.init(x: diameter * 0.40, y: diameter / 2 + diameter * 0.16)
    
    p.move(to: topLeft)
    p.addLine(to: bottomLeft)
    
    let topRight = CGPoint.init(x:  diameter - diameter * 0.40, y: diameter / 2 - diameter * 0.16)
    let bottomRight = CGPoint.init(x: diameter - diameter * 0.40, y: diameter / 2 + diameter * 0.16)

    p.move(to: topRight)
    p.addLine(to: bottomRight)
    
    return p
  }
  
}

struct PlayPauseLoadingIcon_Previews: PreviewProvider {
  static var previews: some View {
    PlayPauseLoadingIcon(state: .constant(.playing))
      .frame(width:100,height:100)
  }
}
