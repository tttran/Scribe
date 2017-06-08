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



class ViewController: UIViewController, OEEventsObserverDelegate {

    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var transcriptionTextField: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    var recording = false
    var slt = Slt()
    var openEarsEventsObserver = OEEventsObserver()
    var fliteController = OEFliteController()
    
    var usingStartingLanguageModel = Bool()
    var pathToFirstDynamicallyGeneratedLanguageModel: String!
    var pathToFirstDynamicallyGeneratedDictionary: String!
    var pathToSecondDynamicallyGeneratedLanguageModel: String!
    var pathToSecondDynamicallyGeneratedDictionary: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.isHidden = true
        transcriptionTextField.isEditable = false
        
        self.openEarsEventsObserver.delegate = self
        
        let languageModelGenerator = OELanguageModelGenerator()
        
        // This is the language model (vocabulary) we're going to start up with. You can replace these words with the words you want to use.
        
        let firstLanguageArray = ["sort",
                                  "by",
                                  "name",
                                  "PDF",
                                  "View",
                                  "Execute",
                                  "Dossier",
                                  "Logout"]
        
        let firstVocabularyName = "FirstVocabulary"
        
        // languageModelGenerator.verboseLanguageModelGenerator = true // Uncomment me for verbose language model generator debug output to either diagnose your issue or provide information relating to language model generation when asking for help at the forums.
        // OELogging.startOpenEarsLogging() // If you encounter any issues, set this to true to get verbose logging output from OpenEars to either diagnose your issue or provide information when asking for help at the forums.
      
        
        
        
        
        
        let firstLanguageModelGenerationError: Error! = languageModelGenerator.generateLanguageModel(from: firstLanguageArray, withFilesNamed: firstVocabularyName, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish")) // Change "AcousticModelEnglish" to "AcousticModelSpanish" in order to create a language model for Spanish recognition instead of English.
        
        if(firstLanguageModelGenerationError != nil) {
            print("Error while creating initial language model: \(firstLanguageModelGenerationError)")
        } else {
            self.pathToFirstDynamicallyGeneratedLanguageModel = languageModelGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: firstVocabularyName) // these are convenience methods you can use to reference the file location of a language model that is known to have been created successfully.
            self.pathToFirstDynamicallyGeneratedDictionary = languageModelGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: firstVocabularyName) // these are convenience methods you can use to reference the file location of a dictionary that is known to have been created successfully.
            self.usingStartingLanguageModel = true // Just keeping track of which model we're using.
            
            // This is a model we will switch to when the user speaks "change model". The last entry, quidnunc, is an example of a word which will not be found in the lookup dictionary and will be passed to the fallback method. The fallback method is slower, so, for instance, creating a new language model from dictionary words will be pretty fast, but a model that has a lot of unusual names in it or invented/rare/recent-slang words will be slower to generate. You can use this information to give your users some UI feedback about what the expectations for wait times should be. However, on modern devices this is not expected to be a multi-second process if the vocabulary is within the supported size of 2000 words or fewer. Using "change model" as all one string in this array gives it a somewhat higher likelihood of being recognized as a phrase.
            
            let secondVocabularyName = "SecondVocabulary"
            
            let secondLanguageArray = ["Sunday",
                                       "Monday",
                                       "Tuesday",
                                       "Wednesday",
                                       "Thursday",
                                       "Friday",
                                       "Saturday",
                                       "quidnunc",
                                       "change model"]
            
            let secondLanguageModelGenerationError: Error! = languageModelGenerator.generateLanguageModel(from: secondLanguageArray, withFilesNamed: secondVocabularyName, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish")) // Change "AcousticModelEnglish" to "AcousticModelSpanish" in order to create a language model for Spanish recognition instead of English.
            
            if(secondLanguageModelGenerationError != nil) {
                print("Error while creating second language model: \(secondLanguageModelGenerationError)")
            } else {
                self.pathToSecondDynamicallyGeneratedLanguageModel = languageModelGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: secondVocabularyName)  // these are convenience methods you can use to reference the file location of a language model that is known to have been created successfully.
                self.pathToSecondDynamicallyGeneratedDictionary = languageModelGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: secondVocabularyName) // these are convenience methods you can use to reference the file location of a dictionary that is known to have been created successfully.
                
                do {
                    try OEPocketsphinxController.sharedInstance().setActive(true) // Setting the shared OEPocketsphinxController active is necessary before any of its properties are accessed.
                }
                catch {
                    print("Error: it wasn't possible to set the shared instance to active: \"\(error)\"")
                }
                
                // OEPocketsphinxController.sharedInstance().verbosePocketSphinx = true // If you encounter any issues, set this to true to get verbose logging output from OEPocketsphinxController to either diagnose your issue or provide information when asking for help at the forums.
                
                if(!OEPocketsphinxController.sharedInstance().isListening) {
                    OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
                }
                // Here is some UI stuff that has nothing specifically to do with OpenEars implementation
              
            }
        }
    }
    
 
    
    func startListening() {
        if(!OEPocketsphinxController.sharedInstance().isListening) {
            OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
        }

    }
    
    func stopListening() {
        if(OEPocketsphinxController.sharedInstance().isListening){
            let stopListeningError: Error! = OEPocketsphinxController.sharedInstance().stopListening()
            if(stopListeningError != nil) {
                print("Error while stopping listening in pocketsphinxFailedNoMicPermissions: \(stopListeningError)")
            }
        }
    }
    /*
    func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        print("Local callback: The received hypothesis is \(hypothesis!) with a score of \(recognitionScore!) and an ID of \(utteranceID!)")
        if(hypothesis! == "change model") {
            if(self.usingStartingLanguageModel) {
                OEPocketsphinxController.sharedInstance().changeLanguageModel(toFile: self.pathToSecondDynamicallyGeneratedLanguageModel, withDictionary:self.pathToSecondDynamicallyGeneratedDictionary)
                self.usingStartingLanguageModel = false
            } else {
                OEPocketsphinxController.sharedInstance().changeLanguageModel(toFile: self.pathToFirstDynamicallyGeneratedLanguageModel, withDictionary:self.pathToFirstDynamicallyGeneratedDictionary)
                self.usingStartingLanguageModel = true
            }
        }
        self.transcriptionTextField.text = "Heard: \"\(hypothesis!)\""
    }*/
    
    func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) { //
        print("Local callback: The received hypothesis is \(hypothesis!) with a score of \(recognitionScore!) and an ID of \(utteranceID!)")
        self.transcriptionTextField.text = "Heard: \"\(hypothesis!)\""

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

