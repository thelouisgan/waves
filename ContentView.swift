import SwiftUI
import Keyboard
import AVFoundation
import AudioToolbox

// Accessing individual elements
// let chordInKeyC = majorScaleChords[4][2] // "Dm"


struct ContentView: View {
    var body: some View {
        
        
        
        
        /*if let fileURL = Bundle.main.url(forResource: "Piano", withExtension: "wav", subdirectory: "Sounds") {
            Text("File found at \(fileURL)")
        } else {
            Text("Not found")
        }
        
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

/*
class Records: ObservableObject {
    @Published var startTime: Date?
    @Published var pitchNote: [Int] = []
    @Published var timeElapsed: Double?
    @Published var noteState: Bool?
    
    func startRecording() {
        startTime = Date()
    }
    
    func stopRecording() {
        startTime = nil
    }
    
    func addRecord(keyPress: [Int], state: Bool) {
        guard let startTime = startTime else { return }
        let timestamp = Date().timeIntervalSince(startTime)
        timeElapsed = timestamp
        pitchNote = keyPress
        noteState = state
    }
}*/
