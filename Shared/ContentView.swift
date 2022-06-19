//
//  ContentView.swift
//  Shared
//
//  Created by AbuTalha on 19/06/2022.
//

import SwiftUI
import AVFoundation

let speechText = "How to highlight text to speech words being read using AVSpeechSynthesizer. iOS has text-to-speech synthesis built right into the system, but even better is that it allows you to track when individual words are being spoken so that you can highlight the words on the screen. Finally, you need to trigger the text-to-speech engine – this might be by a button press perhaps, but it's down to you. Here's the method I attached to a button press: iOS is an operating system with many possibilities, allowing to create from really simple to super-advanced applications. There are times where applications have to be multi-featured, providing elegant solutions that exceed the limits of the common places, and lead to a superb user experience. Also, there are numerous technologies one could exploit, and in this tutorial we are going to focus on one of them, which is no other than the Text to Speech. Text-to-speech (TTS) is not something new in iOS 8. Since iOS 7 dealing with TTS has been really easy, as the code required to make an app speak is straightforward and easy to be handled. To make things more precise, iOS 7 introduced a new class named AVSpeechSynthesizer, and as you understand from its prefix it’s part of the powerful AVFoundation framework."

struct ContentView: View {
    
    @StateObject var svm = SynthViewModel(speechText: speechText)
    
    var body: some View {
        VStack {
            Text("Read Aloud").bold()
                .font(.headline)
            ScrollView {
                Text(speechText) { string in
                    string[svm.speakingRange].foregroundColor = .black
                    string[svm.speakingRange].backgroundColor = .yellow
                }
            }
            
            HStack {
                Button("Speak") {
                    startReading()
                }
                Button("Stop") {
                    stopReading()
                }
            }
            .padding()
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    func startReading() {
        svm.speak()
    }
    
    func stopReading() {
        svm.stop()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/// extension to make applying AttributedString even easier
extension Text {
    init(_ string: String, configure: ((inout AttributedString) -> Void)) {
        var attributedString = AttributedString(string) /// create an `AttributedString`
        configure(&attributedString) /// configure using the closure
        self.init(attributedString) /// initialize a `Text`
    }
}

class SynthViewModel: NSObject, ObservableObject {
    private var speechSynthesizer = AVSpeechSynthesizer()
    @Published var speakingRange: Range<AttributedString.Index>
    var speechText: String = ""

    override init() {
        speakingRange = Range(NSMakeRange(0,0), in: AttributedString(speechText))!
        super.init()
        self.speechSynthesizer.delegate = self
    }
    
    convenience init(speechText: String) {
        self.init()
        self.speechText = speechText
    }
    
    func speak() {
        let utterance = AVSpeechUtterance(string: speechText)
        speechSynthesizer.speak(utterance)
    }
    
    func stop() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
//    func getRange() -> ClosedRange<String.Index> {
//        let startIndex = speechText.index(speechText.startIndex, offsetBy: speakingRange.location)
//        let endIndex = speechText.index(startIndex, offsetBy: speakingRange.length)
//        return (startIndex...endIndex)
//    }
}

extension SynthViewModel: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("started")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("paused")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("didContinue")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("didCancel")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if let range = Range(characterRange, in: AttributedString(speechText)) {
            speakingRange = range
        }
        print("utterance... \(characterRange)")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("finished")
    }
}
