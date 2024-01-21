//
//  KeySelector.swift
//  waves
//
//  Created by Louis Gan on 08/02/2024.
//

import SwiftUI

struct KeySelector: View {
    let majorScaleChords: [(keys: String, value: [String])] = [
        ("Ab", ["Ab", "Bbm", "Cm", "Db", "Eb", "Fm", "Gdim"]),
        ("A", ["A", "Bm", "C#m", "D", "E", "F#m", "G#dim"]),
        ("Bb", ["Bb", "Cm", "Dm", "Eb", "F", "Gm", "Adim"]),
        ("B", ["B", "C#m", "D#m", "E", "F#", "G#m", "A#dim"]),
        ("C", ["C", "Dm", "Em", "F", "G", "Am", "Bdim"]),
        ("C#", ["C#", "D#m", "E#m", "F#", "G#", "A#m", "B#dim"]),
        ("Db", ["Db", "Ebm", "Fm", "Gb", "Ab", "Bbm", "Cdim"]),
        ("D", ["D", "Em", "F#m", "G", "A", "Bm", "C#dim"]),
        ("Eb", ["Eb", "Fm", "Gm", "Ab", "Bb", "Cm", "Ddim"]),
        ("E", ["E", "F#m", "G#m", "A", "B", "C#m", "D#dim"]),
        ("F", ["F", "Gm", "Am", "Bb", "C", "Dm", "Edim"]),
        ("F#", ["F#", "G#m", "A#m", "B", "C#", "D#m", "E#dim"]),
        ("Gb", ["Gb", "Abm", "Bbm", "Cb", "Db", "Ebm", "Fdim"]),
        ("G", ["G", "Am", "Bm", "C", "D", "Em", "F#dim"])
    ]
    
    let minorScaleChords: [(keys: String, value: [String])] = [
        ("Abm", ["Abm", "Bbdim", "Cb", "Dbm", "Ebm", "Fb", "Gb"]),
        ("Am", ["Am", "Bdim", "C", "Dm", "Em", "F", "G"]),
        ("Bbm", ["Bbm", "Cdim", "Db", "Ebm", "Fm", "Gb", "Ab"]),
        ("Bm", ["Bm", "C#dim", "D", "Em", "F#m", "G", "A"]),
        ("Cm", ["Cm", "Ddim", "Eb", "Fm", "Gm", "Ab", "Bb"]),
        ("C#m", ["C#m", "D#dim", "E", "F#m", "G#m", "A", "B"]),
        ("Dm", ["Dm", "Edim", "F", "Gm", "Am", "Bb", "C"]),
        ("Ebm", ["Ebm", "Fdim", "Gb", "Abm", "Bbm", "Cb", "Db"]),
        ("Em", ["Em", "F#dim", "G", "Am", "Bm", "C", "D"]),
        ("Fm", ["Fm", "Gdim", "Ab", "Bbm", "Cm", "Db", "Eb"]),
        ("F#m", ["F#m", "G#dim", "A", "Bm", "C#m", "D", "E"]),
        ("Gm", ["Gm", "Adim", "Bb", "Cm", "Dm", "Eb", "F"]),
        ("G#m", ["G#m", "A#dim", "B", "C#m", "D#m", "E", "F#"])
    ]
    
    
    /*let chordProgressions: [[Int]] = [
     [1, 4, 5, 1],   // I-IV-V-I
     [1, 5, 6, 4],   // I-V-vi-IV
     [1, 6, 4, 5],   // I-vi-IV-V
     [6, 4, 1, 5],   // vi-IV-I-V
     [1, 5, 4, 1],   // i-v-iv-i (assuming lowercase represents minor)
     [1, 6, 2, 5]    // I-vi-ii-V
     ]*/
    
    let chordProgressionsDictionary: [String: [Int]] = [
        "Uplifting": [4, 5, 6, 1],      // IV-V-vi-I (Uplifting progression)
        "Sad1": [6, 4, 1, 5],           // vi-IV-I-V (Sad chord progression 1)
        "Sad2": [6, 3, 5, 4]            // vi-iii-V-IV (Sad chord progression 2)
    ]
    
    // User-selected key and genre
    @State private var selectedKey: String = "C"
    @State private var availableChords: [String] = [
        "C", "Dm", "Em", "F", "G", "Am", "Bdim"
    ]
    @State private var selectedGenre: String = "Uplifting"
    @State private var selectedChords: [(keys: String, value: [String])] = [
        ("Ab", ["Ab", "Bbm", "Cm", "Db", "Eb", "Fm", "Gdim"]),
        ("A", ["A", "Bm", "C#m", "D", "E", "F#m", "G#dim"]),
        ("Bb", ["Bb", "Cm", "Dm", "Eb", "F", "Gm", "Adim"]),
        ("B", ["B", "C#m", "D#m", "E", "F#", "G#m", "A#dim"]),
        ("C", ["C", "Dm", "Em", "F", "G", "Am", "Bdim"]),
        ("C#", ["C#", "D#m", "E#m", "F#", "G#", "A#m", "B#dim"]),
        ("Db", ["Db", "Ebm", "Fm", "Gb", "Ab", "Bbm", "Cdim"]),
        ("D", ["D", "Em", "F#m", "G", "A", "Bm", "C#dim"]),
        ("Eb", ["Eb", "Fm", "Gm", "Ab", "Bb", "Cm", "Ddim"]),
        ("E", ["E", "F#m", "G#m", "A", "B", "C#m", "D#dim"]),
        ("F", ["F", "Gm", "Am", "Bb", "C", "Dm", "Edim"]),
        ("F#", ["F#", "G#m", "A#m", "B", "C#", "D#m", "E#dim"]),
        ("Gb", ["Gb", "Abm", "Bbm", "Cb", "Db", "Ebm", "Fdim"]),
        ("G", ["G", "Am", "Bm", "C", "D", "Em", "F#dim"])
    ]
    
    
    var body: some View {
        VStack {
            
            
            
            Text("Choose a genre:")
            Picker("Genre", selection: $selectedGenre) {
                ForEach(Array(chordProgressionsDictionary.keys), id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedGenre) {newKey in
                if selectedGenre == "Sad2" || selectedGenre == "Sad1" {
                    selectedChords = minorScaleChords
                }
                else {
                    selectedChords = majorScaleChords
                }
            }
            
            Text("Choose a key:")
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 4), spacing: 10) {
                ForEach(selectedChords, id: \.0) { chordTuple in
                    let (key, chords) = chordTuple
                    Button(action: {
                        selectedKey = key  // Update selectedKey when the button is tapped
                        availableChords = chords
                    }) {
                        Text(key)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedKey == key ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            
            
            
            /*Button(action: generateChordProgression) {
             Text("Generate Chord Progression")
             .padding()
             .background(Color.blue)
             .foregroundColor(.white)
             .cornerRadius(10)
             }*/
            
            // Display the generated chord progression
            if let chordProgression = getChordProgression() {
                Text("Chord Progression: \(chordProgression)")
                    .padding()
            }
        }
        .padding()
    }
    
    
    
    // Function to get chord progression based on user input
    func generateChordProgression() {
        // Perform any additional actions if needed
    }
    
    // Function to retrieve the chord progression based on user input
    /*
     func getChordProgression() -> String? {
     if majorScaleChords[selectedKey] != nil {
     // Major key selected
     let chords = chordProgressionsDictionary[selectedGenre] ?? []
     return chords.compactMap { majorScaleChords[selectedKey]?[$0 - 1] }.joined(separator: " - ")
     } else if minorScaleChords[selectedKey] != nil {
     // Minor key selected
     let chords = chordProgressionsDictionary[selectedGenre] ?? []
     return chords.compactMap { minorScaleChords[selectedKey]?[$0 - 1] }.joined(separator: " - ")
     } else {
     return nil
     }
     }*/
    
    func getChordProgression() -> String? {
        if let progression = chordProgressionsDictionary[selectedGenre] {
            var progressionString = ""
            for chordIndex in progression {
                let chord = availableChords[chordIndex - 1] // Adjust index to match array (1-indexed)
                progressionString += "\(chord) - "
            }
            // Remove the trailing " - " from the string
            progressionString.removeLast(3)
            return progressionString
        } else {
            return nil
        }
    }
}
