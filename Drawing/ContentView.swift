import SwiftUI

struct ContentView: View {
  
  @State var progressInSeconds : Double = 0
  @State var lenghtOfAudio : Double = 0
  @State var state : AudioPlayerState = .readyToPlay
  
  let audioPlayer = AudioPlayer()
  
  var body: some View {
    AudioPlayerView(
      state: $state,progressInSeconds: $progressInSeconds,
      lenghtOfVideosInSeconds: $lenghtOfAudio,
      onTapPlay: {
        if audioPlayer.isAudioReadyToPlay() {
          self.audioPlayer.setSeekToTimePlayer(seconds: progressInSeconds)
          self.audioPlayer.play()
          state = .playing
        }else {
          state = .loading
          audioPlayer.loadAudioUrl(audioURL: "https://ik.imagekit.io/notifyme/dev/media/audio_files/18579/jq2n1qmmf9fy8nu4lx2i.mp3", seconds: 0)
        }
      },
      onPause:  {
        audioPlayer.pauseAudio()
      },
      onDarg:  {
        audioPlayer.pauseAudio()
        state = .readyToPlay
      }
    )
      .frame(height: 55)
      .onAppear {
        audioPlayer.audioPlayerReadyToPlayWithDuration { lenght in
          self.state = .playing
          self.lenghtOfAudio = lenght
          self.audioPlayer.play()
        }.onPlayingCurrentTime { progress in
          self.progressInSeconds = progress
        }.onEndCurrentItem {
          self.progressInSeconds = 0
          self.state = .readyToPlay
        }
      }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
