//
//  ViewController.swift
//  ScoreCardSiri
//
//  Created by amgen on 15/03/17.
//  Copyright © 2017 amgen. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,AVAudioPlayerDelegate,SpeechTextDelegate {
    var audioPlayer: AVAudioPlayer?
    var audioPlayerSiriSound: AVAudioPlayer?
    var getSoundPath: NSURL?
    var timer : Timer?
    let getresult = SpeechToText()
    
    @IBOutlet weak var animationView: UIImageView!
    @IBOutlet weak var micView: UIImageView!
    @IBOutlet weak var micButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getresult.initializeSpeech()
        getresult.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func playSiriSound()
    {
        audioPlayerSiriSound = nil
        let siriSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "siri", ofType: "mp3")!)
        do {
            try audioPlayerSiriSound = AVAudioPlayer(contentsOf: siriSound as URL)
            audioPlayerSiriSound?.delegate = self
            audioPlayerSiriSound?.prepareToPlay()
            audioPlayerSiriSound?.play()
        } catch let error as NSError {
            print("audioPlayer error \(error.localizedDescription)")
        }
    }
    
    func animateImage()
    {
        self.stopAnimateImage()
        var images: [UIImage] = []
        for i in 1...46 {
            images.append(UIImage(named: "\(i)")!)
        }
        self.animationView.animationImages = images;
        self.animationView.animationDuration = 2.0
        self.animationView.startAnimating()
    }
    
    func stopAnimateImage()
    {
        if self.animationView.isAnimating
        {
            self.animationView.stopAnimating()
        }
    }
    
    func startTimer()
    {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(saySomething), userInfo: nil, repeats: false)
        self.getresult.stopRecognizing()
        DispatchQueue.global().async{
            self.getresult.recordVoice()
        }
    }
    
    func speakThisText(txt:String)
    {
        self.stopAnimateImage()
        self.timer?.invalidate()
        audioPlayer = nil
        audioPlayerSiriSound = nil
        let speech = FliteTTS.init()
        speech.setVoice("cmu_us_slt")
        speech.setPitch(200.0, variance: 50.0, speed: 1.0)
        let paths = speech.speakText(txt, with: audioPlayer)
        getSoundPath = NSURL(fileURLWithPath: paths!)
        let fileManager : FileManager   = FileManager.default
        if fileManager.fileExists(atPath:(getSoundPath?.absoluteURL?.path)!)
        {
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: (getSoundPath?.absoluteURL!)!)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch let error as NSError {
                print("audioPlayer error \(error.localizedDescription)")
            }
        }

    }
    
    func disableMic()
    {
        self.micButton.isUserInteractionEnabled=false
        self.micButton.isEnabled = false
        self.micButton.alpha = 0.5
    }
    
    func enableMic()
    {
        self.micButton.isUserInteractionEnabled=true
        self.micButton.isEnabled = true
        self.micButton.alpha = 1
    }
    
    func saySomething()
    {
        self.getresult.stopRecognizing()
        self.speakThisText(txt: "Say Something Buddy I'm Listening You")
    }
    
    @IBAction func speakout(_ sender: AnyObject)
    {
        self.speakThisText(txt: "Are you Safe Buddy?")
    }
    
    
    // MARK:- Audio Player Delegate Methods
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully
        flag: Bool)
    {
        let fileManager : FileManager   = FileManager.default
        if audioPlayerSiriSound != nil
        {
            DispatchQueue.main.async {
                self.startTimer()
            }
        }
        else
        {
            if getSoundPath != nil
            {
                if fileManager.fileExists(atPath:(getSoundPath?.absoluteURL?.path)!)
                {
                    do{
                        try fileManager.removeItem(atPath: (getSoundPath?.absoluteURL?.path)!)
                        getSoundPath = nil
                        self.animateImage()
                        DispatchQueue.global().async{
                            self.playSiriSound()
                        }
                    }
                    catch let error as NSError {
                        print("audioPlayer error \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer,
                                        error: Error?) {
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer) {
    }
    
    //MARK:- SpeechRecognition Delegate
    func getresult(txt: String)
    {
        if !txt.isEmpty
        {
            self.timer?.invalidate()
            var usaid = "you said"
            usaid = usaid.appending(txt)
            self.speakThisText(txt: usaid)
        }
    }
}

