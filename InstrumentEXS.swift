import AudioKit
import AVFoundation
import SwiftUI
import Keyboard
import Tonic

class InstrumentEXSConductor: ObservableObject {
    @Published var conductor = Conductor()
    @Published var currentPitch: Pitch?
    
    @Published var startTime: Date?
    @Published var pitchNote: Pitch?
    @Published var timeElapsed: Double?
    @Published var noteState: Bool?
    
    let midi = MIDI()

    func noteOn(pitch: Pitch, point: CGPoint) {
        conductor.instrument.play(noteNumber: MIDINoteNumber(pitch.intValue), velocity: 90, channel: 0)
        currentPitch = pitch // Update the current pitch
        addRecord(keyPress: pitch, state: true)
    }

    func noteOff(pitch: Pitch) {
        conductor.instrument.stop(noteNumber: MIDINoteNumber(pitch.intValue), channel: 0)
        currentPitch = nil // Clear the current pitch when note is released
        addRecord(keyPress: pitch, state: false)
    }
    
    func startRecording() {
        startTime = Date()
    }
    
    func stopRecording() {
        startTime = nil
    }
    
    func addRecord(keyPress: Pitch, state: Bool) {
        guard let startTime = startTime else { return }
        let timestamp = Date().timeIntervalSince(startTime)
        timeElapsed = timestamp
        pitchNote = keyPress
        noteState = state
        //print("timeElapsed: \(timeElapsed), pitchNote: \(pitchNote), noteState: \(noteState)")
        print(timeElapsed!)
        print(pitchNote!)
        print(noteState!)
    }

    init() {
        midi.addListener(self)
    }
    
    func start() {
        // Load EXS file (you can also load SoundFonts and WAV files too using the AppleSampler Class)
        do {
            if let fileURL = Bundle.main.url(forResource: "Sounds/SquareInstrument", withExtension: "exs") {
                try conductor.instrument.loadInstrument(url: fileURL)
            } else {
                Log("Could not find file")
            }
        } catch {
            Log("Could not load instrument")
        }
        do {
            try conductor.engine.start()
        } catch {
            Log("AudioKit did not start!")
        }
        midi.openInput()
    }
    
    func stop() {
        conductor.engine.stop()
        midi.closeAllInputs()
    }
}

struct InstrumentEXSView: View {
    @StateObject var instrumentEXSConductor = InstrumentEXSConductor()
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @State private var isRecording = false
    var backgroundMode = true // This variable controls the background audio state. Your users might want to disable it to save on battery usage.
    
    var body: some View {
        VStack {
            HStack {
                if isRecording {
                    Text("Recording...")
                        .foregroundColor(.red)
                } else {
                    Text("Not Recording")
                        .foregroundColor(.green)
                }
                
                Button(action: {
                    self.toggleRecording()
                }) {
                    Text(isRecording ? "Stop Recording" : "Start Recording")
                        .padding()
                        .background(isRecording ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    self.saveRecordingsToFile()
                }) {
                    Text("Save Recordings")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            //Spacer()
            Text("Current Pitch: \(instrumentEXSConductor.currentPitch?.intValue.description ?? "None")")
            SwiftUIKeyboard(firstOctave: 2, octaveCount: 2, noteOn: instrumentEXSConductor.noteOn(pitch:point:), noteOff: instrumentEXSConductor.noteOff).frame(maxHeight: 600).padding(10)
        }
        .onAppear {
            if(!self.instrumentEXSConductor.conductor.engine.avEngine.isRunning) {
                Log("Engine Starting")
                self.instrumentEXSConductor.start()
            }
        }
        // Background Engine Start & Stop
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                Log("Active")
                if(!self.instrumentEXSConductor.conductor.engine.avEngine.isRunning) {
                    Log("Engine Starting")
                    self.instrumentEXSConductor.start()
                }
            } else if newPhase == .background {
                Log("Background")
                if(!backgroundMode){
                    Log("Engine Stopped")
                    self.instrumentEXSConductor.stop()
                }
            }
        }
        // Phone Call Start & Stop
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { event in
            guard let info = event.userInfo,
                  let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
            }
            if type == .began {
                // Interruption began, take appropriate actions (save state, update user interface)
                self.instrumentEXSConductor.stop()
            }
            else if type == .ended {
                guard let optionsValue =
                        info[AVAudioSessionInterruptionOptionKey] as? UInt else {
                    return
                }
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Interruption Ended - playback should resume
                    if(self.instrumentEXSConductor.conductor.engine.avEngine.isRunning) {
                        print("Engine Already Running")
                    } else {
                        let deadlineTime = DispatchTime.now() + .milliseconds(1000)
                        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                            self.instrumentEXSConductor.start()
                        }
                    }
                }
            }
        }
        .background(colorScheme == .dark ?
                    Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9))
        
        
    }
    
    func toggleRecording() {
        isRecording.toggle()
        if isRecording {
            instrumentEXSConductor.startRecording()
        } else {
            instrumentEXSConductor.stopRecording()
        }
    }
    
    func saveRecordingsToFile() {
        // Implement logic to save recordings to a text file
        // For demonstration, just print the recordings
        //print(records.recordings)
    }
}

extension InstrumentEXSConductor: MIDIListener {
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        conductor.instrument.play(noteNumber: noteNumber, velocity: velocity, channel: channel)
    }
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        conductor.instrument.stop(noteNumber: noteNumber, channel: channel)
    }
    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        conductor.instrument.midiCC(1, value: value, channel: channel)
    }
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        conductor.instrument.setPitchbend(amount: pitchWheelValue, channel: channel)
    }
    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber, pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) { }
    func receivedMIDIAftertouch(_ pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) { }
    func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) { }
    func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) { }
    func receivedMIDISetupChange() { }
    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) { }
    func receivedMIDINotification(notification: MIDINotification) { }
}


struct InstrumentEXSView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentEXSView()
    }
}
