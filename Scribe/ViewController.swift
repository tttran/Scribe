//
//  ViewController.swift
//  Scribe
//
//  Created by Tran, Timothy on 6/7/17.
//  Copyright © 2017 Tran, Timothy. All rights reserved.
//

import UIKit
import Intents


class ViewController: UIViewController, OEEventsObserverDelegate {

    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var transcriptionTextField: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    var recording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.isHidden = true
        transcriptionTextField.isEditable = false

        // Ask permission to access Siri
        INPreferences.requestSiriAuthorization { authorizationStatus in
            switch authorizationStatus {
            case .authorized:
                print("Authorized")
            default:
                print("Not Authorized")
            }
        }
    }
 
    
    func startListening() {
        
    }
    
    func stopListening() {
    
    }
    
 
    
  
    @IBAction func playBtnPressed(_ sender: CircleButton) {
        if (recording == false) {
            recording = true
            statusLabel.text = "Click again to stop recording"
            activitySpinner.isHidden = false
            activitySpinner.startAnimating()
            startListening()
        }
        else {
            recording = false
            statusLabel.text = "PLAY & TRANSCRIBE"
            activitySpinner.stopAnimating()
            activitySpinner.isHidden = true
            stopListening()
        }
    }
}

