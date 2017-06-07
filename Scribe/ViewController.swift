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



class ViewController: UIViewController {

    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var transcriptionTextField: UITextView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var recording = false;
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.isHidden = true
        transcriptionTextField.isEditable = false
        
        let lmGenerator = OELanguageModelGenerator()
        let words = ["word", "Statement", "other word", "A PHRASE"] // These can be lowercase, uppercase, or mixed-case.
        let name = "NameIWantForMyLanguageModelFiles"
        let err: Error! = lmGenerator.generateLanguageModel(from: words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
        
        if(err != nil) {
            print("Error while creating initial language model: \(err)")
        } else {
            let lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: name) // Convenience method to reference the path of a language model known to have been created successfully.
            let dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: name) // Convenience method to reference the path of a dictionary known to have been created successfully.
        }
        
    }

    
    
    
    
    
    @IBAction func playBtnPressed(_ sender: CircleButton) {
        if (recording == false) {
            recording = true
            statusLabel.text = "Click again to stop recording"
            activitySpinner.isHidden = false
            activitySpinner.startAnimating()
            
        }
        else {
            recording = false
            statusLabel.text = "PLAY & TRANSCRIBE"
            activitySpinner.stopAnimating()
            activitySpinner.isHidden = true
        }
        
    }
    
    
    
}

