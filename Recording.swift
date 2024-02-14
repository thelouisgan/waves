/*import SwiftUI

struct Recording: View {
    @State private var records = Records()
    @State private var isRecording = false
    
    
    
    func toggleRecording() {
        isRecording.toggle()
        if isRecording {
            records.startRecording()
        } else {
            records.stopRecording()
        }
    }
    
    func saveRecordingsToFile() {
        // Implement logic to save recordings to a text file
        // For demonstration, just print the recordings
        print(records.recordings)
    }
}

struct KeyboardView: View {
    @Binding var records: Records
    
    var body: some View {
        VStack {
            ForEach(0..<5) { row in
                HStack {
                    ForEach(0..<7) { column in
                        KeyView(records: $records)
                    }
                }
            }
        }
    }
}

struct KeyView: View {
    @Binding var records: Records
    
    var body: some View {
        Button(action: {
            records.addRecord()
        }) {
            Text("Key")
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(5)
        }
    }
}

class Records: ObservableObject {
    @Published var startTime: Date?
    @Published var recordings: [String] = []
    
    func startRecording() {
        startTime = Date()
    }
    
    func stopRecording() {
        startTime = nil
    }
    
    func addRecord() {
        guard let startTime = startTime else { return }
        let timestamp = Date().timeIntervalSince(startTime)
        recordings.append("\(timestamp)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/
