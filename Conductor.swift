import AudioKit
import AVFoundation
import AudioToolbox


class Conductor: ObservableObject {

    let engine = AudioEngine()
    var instrument = MIDISampler(name: "Instrument 1")
    @Published var verb: Reverb
    
    //let sequencer = AppleSequencer?
    

    init() {
        verb = Reverb(instrument)
        verb.dryWetMix = 0.3
        engine.output = verb
    }

    func start() {
        // Load EXS file (you can also load SoundFonts and WAV files too using the AppleSampler Class)
        do {
            if let fileURL = Bundle.main.url(forResource: "Sounds/Piano", withExtension: "wav") {
                try instrument.loadInstrument(url: fileURL)
            } else {
                Log("Could not find file")
            }
        } catch {
            Log("Could not load instrument")
        }
        do {
            try engine.start()
            //try sequencer.start()
        } catch {
            Log("AudioKit did not start!")
        }
    }

    func stop() {
        engine.stop()
    }
}
