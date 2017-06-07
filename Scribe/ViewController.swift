//
//  ViewController.swift
//  Scribe
//
//  Created by Tran, Timothy on 6/7/17.
//  Copyright © 2017 Tran, Timothy. All rights reserved.
//

import UIKit
import Speech
import AVFoundation


class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var transcriptionTextField: UITextView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var recording = false;
    
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.isHidden = true
        transcriptionTextField.isEditable = false

    }

    
    func requestSpeechAuth() {
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized {
                try! self.startRecording()
            }
        }
    }
    
    func startRecording() throws {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false;
            if let result = result {
                self.transcriptionTextField.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
            }
        }
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        
    }
    
    func stopRecording() {
        self.audioEngine.stop()
        self.recognitionRequest = nil
        recognitionTask?.cancel()
        self.recognitionTask = nil
    }
    
    @IBAction func playBtnPressed(_ sender: CircleButton) {
        if (recording == false) {
            recording = true
            statusLabel.text = "Click again to stop recording"
            activitySpinner.isHidden = false
            activitySpinner.startAnimating()
            
            requestSpeechAuth()
        }
        else {
            recording = false
            statusLabel.text = "PLAY & TRANSCRIBE"
            activitySpinner.stopAnimating()
            activitySpinner.isHidden = true
            stopRecording()
        }
        
    }
    
    
    
}

