import AudioKit
import AVFoundation
import SwiftUI
import Keyboard
import Tonic

import AudioKitEX
import AudioKitUI

import AudioToolbox
import CoreAudioKit

import CoreMIDI

protocol InstrumentEXSDelegate {
    func toggle()
}

struct RecorderData {
    var isRecording = false
    var isPlaying = false
}

class RecorderConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var sequencer = AppleSequencer()
    var recorder: NodeRecorder?
    let player = AudioPlayer()
    var silencer: Fader?
    let mixer = Mixer()

    @Published var data = RecorderData() {
        didSet {
            if data.isRecording {
                do {
                    try recorder?.record()
                } catch let err {
                    print(err)
                }
            } else {
                recorder?.stop()
            }

            if data.isPlaying {
                if let file = recorder?.audioFile {
                    try? player.load(file: file)
                    player.play()
                }
            } else {
                player.stop()
            }
        }
    }

    init() {
        guard let input = engine.input else {
            fatalError()
        }

        do {
            recorder = try NodeRecorder(node: input)
        } catch let err {
            fatalError("\(err)")
        }
        let silencer = Fader(input, gain: 0)
        self.silencer = silencer
        mixer.addInput(silencer)
        mixer.addInput(player)
        engine.output = mixer
    }
}

struct MIDIEvent {
    let noteNumber: MIDINoteNumber
    let velocity: MIDIVelocity
    let position: Duration
    let duration: Duration
}

extension Duration {
    var inBeats: MusicTimeStamp {
        return MusicTimeStamp(self.seconds * 480.0 / 60.0)  // Assuming 480 ticks per quarter note
    }
}



class InstrumentEXSConductor: ObservableObject {
    @Published var conductor = Conductor()
    @Published var sequencer: AppleSequencer?
    @Published var currentPitch: Pitch?
    
    @Published var startTime: Date?
    @Published var pitchNote: Pitch?
    @Published var timeElapsed: Double?
    @Published var noteState: Bool?
    
    var manager: MusicTrackManager?
    
    var delegate: InstrumentEXSDelegate?
    
    private var timer: Timer = Timer()
    private var secondsElapsed = 0
    
    var RecordingsArray: [Recordings] = []
    
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
    
    var instrumentEXSViewReference: InstrumentEXSView?
    
    func startRecording() {
        startTime = Date()
        timer.invalidate()
        
        
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                self.secondsElapsed = self.secondsElapsed + 1
                print(self.secondsElapsed)
                if self.secondsElapsed >= 10 {
                    timer.invalidate()
                    print("counting done")
                    self.stopRecording()
                    self.instrumentEXSViewReference?.toggleRecording()
                }
            }
        }
    }
    
    func stopRecording() {
        var midiEvents: [MIDIEvent] = []
        var tempRecording = RecordingsArray
        startTime = nil
        secondsElapsed = 0
        delegate?.toggle()
        print("recording done")

        for note in RecordingsArray {
            print("Time Elapsed: \(note.timeElapsed), Pitch Note: \(note.pitchNote), Note State: \(note.noteState ? "On" : "Off")")

            if note.noteState == true {
                for tempPitch in tempRecording {
                    if note.pitchNote == tempPitch.pitchNote && tempPitch.noteState == false {
                        let duration = Duration(seconds: tempPitch.timeElapsed - note.timeElapsed)
                        let position = Duration(seconds: note.timeElapsed)
                        let midiEvent = MIDIEvent(noteNumber: MIDINoteNumber(note.pitchNote.intValue), velocity: 90, position: position, duration: duration)
                        midiEvents.append(midiEvent)
                        break
                    }
                }
            }
        }

        // Create a MIDI file based on MIDI events
        if let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let midiFileURL = documentsDirectoryURL.appendingPathComponent("output.mid")

            // Create a MusicSequence
            var sequence: MusicSequence?
            NewMusicSequence(&sequence)

            // Create a MusicTrack manually
            var track: MusicTrack?
            MusicSequenceNewTrack(sequence!, &track)

            // Add MIDI events to the track
            for event in midiEvents {
                MusicTrackNewMIDIEvent(track!, event.position.inBeats, event.noteNumber, event.velocity, event.duration.inBeats)
            }

            // Save the sequence to a MIDI file
            var musicData: Unmanaged<CFData>?
            MusicSequenceFileCreateData(sequence!, .midiType, .eraseFile, 480, &musicData)

            if let data = musicData?.takeRetainedValue() as Data? {
                do {
                    try data.write(to: midiFileURL)
                    print("MIDI file created at: \(midiFileURL)")
                } catch {
                    print("Error writing MIDI file: \(error)")
                }
            }
        }
    }

    
    func addRecord(keyPress: Pitch, state: Bool) {
        guard let startTime = startTime else { return }
        let timestamp = Date().timeIntervalSince(startTime)
        
        //print("timeElapsed: \(timeElapsed), pitchNote: \(pitchNote), noteState: \(noteState)")
        /*print(timeElapsed!)
        print(pitchNote!)
        print(noteState!)*/
        
        let note = Recordings(startTime: startTime, timeElapsed: timestamp, pitchNote: keyPress, noteState: state)
        RecordingsArray.append(note)
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
    
    func playRecording() {
        
        if let sequencer = sequencer {
            sequencer.play()
        }
        
        // Implement logic to play the recorded notes
        // conductor.instrument.play(noteNumber: MIDINoteNumber(60), velocity: 90, channel: 0)

        /*
        var currentTime: Double = 0.0
        var currentIndex: Int = 0

        let startTime = Date().timeIntervalSince1970  // Capture the starting time

        let playbackChannel: MIDIChannelNumber = 1  // Choose a specific MIDI channel for playback

        while currentIndex < RecordingsArray.count {
            let recording = RecordingsArray[currentIndex]

            // Calculate the currentTime relative to the starting time
            currentTime = Date().timeIntervalSince1970 - startTime

            // Check if the current time matches the timeElapsed in the recording
            if currentTime >= recording.timeElapsed {
                // Execute the noteEvent based on the noteState
                if recording.noteState {
                    // Call noteOn method with the playback channel
                    conductor.instrument.play(noteNumber: MIDINoteNumber(recording.pitchNote.intValue), velocity: 90, channel: playbackChannel)
                } else {
                    // Call noteOff method with the playback channel
                    conductor.instrument.stop(noteNumber: MIDINoteNumber(recording.pitchNote.intValue), channel: playbackChannel)
                }

                // Move to the next recording in the array
                currentIndex += 1
            }

            // Sleep or use an appropriate mechanism to control the loop frequency
            // to avoid unnecessary CPU usage
            usleep(10000) // Sleep for 10 milliseconds, adjust as needed
        }*/
    }

}

struct InstrumentEXSView: View, InstrumentEXSDelegate {
    @StateObject var conductor = RecorderConductor()
    @StateObject var instrumentEXSConductor = InstrumentEXSConductor()
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @State private var isRecording = false
    var backgroundMode = true // This variable controls the background audio state. Your users might want to disable it to save on battery usage.
    
    func toggle() {
        isRecording.toggle()
    }
    var body: some View {
        VStack {
            HStack {
                /*Text(conductor.data.isRecording ? "STOP RECORDING" : "RECORD")
                    .foregroundColor(.blue)
                    .onTapGesture {
                    conductor.data.isRecording.toggle()
                }
                Spacer()
                Text(conductor.data.isPlaying ? "STOP" : "PLAY")
                    .foregroundColor(.blue)
                    .onTapGesture {
                    conductor.data.isPlaying.toggle()
                }*/
                Spacer()
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
                    instrumentEXSConductor.playRecording()
                }) {
                    Text("Play")
                        .padding()
                        .background(Color.teal)
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
            conductor.start()
            instrumentEXSConductor.instrumentEXSViewReference = self
            if(!self.instrumentEXSConductor.conductor.engine.avEngine.isRunning) {
                Log("Engine Starting")
                self.instrumentEXSConductor.start()
            }
        }
        .onDisappear() {
            conductor.stop()
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
        print("Toggle")
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

class Recordings {
    var startTime: Date
    var pitchNote: Pitch
    var timeElapsed: Double
    var noteState: Bool
    
    init(startTime: Date, timeElapsed: Double, pitchNote: Pitch, noteState: Bool) {
        self.startTime = startTime
        self.pitchNote = pitchNote
        self.timeElapsed = timeElapsed
        self.noteState = noteState
    }
}


