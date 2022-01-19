import SwiftUI

struct ContentView: View {
  
  @State var progressInSeconds : Double = 0
  
  var body: some View {
    AudioPlayerView(progressInSeconds: $progressInSeconds, lenghtOfVideosInSeconds: 300)
      .frame(height: 55)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
