//
//  ContentView.swift
//  Drawing
//
//  Created by Nattapong Unaregul on 11/01/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      AudioPlayerView.init()
        .frame(height: 55)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
