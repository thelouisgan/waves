import SwiftUI
import Keyboard
import AVFoundation
import AudioToolbox

// Accessing individual elements
// let chordInKeyC = majorScaleChords[4][2] // "Dm"


struct ContentView: View {
    var body: some View {
        
        
        if let fileURL = Bundle.main.url(forResource: "Piano", withExtension: "wav", subdirectory: "Sounds") {
            Text("File found at \(fileURL)")
        } else {
            Text("Not found")
        }/*
        
        var bundleFiles: [String] {
            guard let bundlePath = Bundle.main.resourcePath,
                  let files = try? FileManager.default.contentsOfDirectory(atPath: bundlePath) else {
                return []
            }
            return files.map {
                "\(bundlePath)/\($0)"
            }
                
        }
        
        ForEach(bundleFiles, id: \.self) { filePath in
            Text(filePath)
        }*/
        
        
        
        VStack {

            KeySelector()
            InstrumentEXSView()
        }
    }
    
    
    /*var body: some View {
     VStack {
     Image(systemName: "globe")
     .imageScale(.large)
     .foregroundColor(.accentColor)
     Text("Hello, world!")
     }
     }*/
}

