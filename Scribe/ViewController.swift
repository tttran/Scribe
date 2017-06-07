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


class ViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var transcriptionTextField: UITextView!
    
    var audioPlayer: AVAudioPlayer!
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop()
        activitySpinner.stopAnimating()
        activitySpinner.isHidden = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func requestSpeechAuth() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized {
                if let path = Bundle.main.url(forResource: "test", withExtension: "m4a") {
                    do {
                        let sound = try AVAudioPlayer(contentsOf: path)
                        self.audioPlayer = sound
                        self.audioPlayer.delegate = self
                        sound.play()
                    } catch {
                        print("Error")
                    }
                    
                    let recognizer = SFSpeechRecognizer()
                    let request = SFSpeechURLRecognitionRequest(url:path)
                    recognizer?.recognitionTask(with: request) { (result, error) in
                        if let error = error {
                            print ("There was an error: \(error)")
                        } else {
                            self.transcriptionTextField.text = result?.bestTranscription.formattedString
                        }
                    
                    }
                }
            }
        }
    }
    @IBAction func playBtnPressed(_ sender: AnyObject) {
        activitySpinner.isHidden = false
        activitySpinner.startAnimating()
        requestSpeechAuth()
    }

}

