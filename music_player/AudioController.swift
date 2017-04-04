//
//  AudioController.swift
//  SpotifyDemo
//
//  Created by inailuy on 9/19/16.
//  Copyright © 2016 yulz. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class AudioController {
    var player :AVPlayer!
    static let sharedInstance = AudioController()
    var currentURL :String!
    var delegate :MusicViewController!
    
    func playPreview(URLString:String) {        
        let url = NSURL(string: URLString)
        player = AVPlayer(url: url! as URL)
        player.play()
        
        currentURL = URLString
        
        observePlayerForInterval()
    }
    
    func pauseAudio() {
        if player.rate == 0 {
            player.play()
        } else {
            player.pause()   
        }
    }
    
    func observePlayerForInterval() {
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(1000,25000), queue: nil) { (time :CMTime) in
            let seconds = CGFloat(time.value) / CGFloat(time.timescale)
            self.delegate.modifySlider(seconds: Float(seconds))
        }
    }

    func playableDuration() -> Float {
        var result = Float(0)
        if player.currentItem?.duration.value != 0 && player.currentItem?.duration.timescale != 0 {
            result = Float(player.currentItem!.duration.value)/Float(player.currentItem!.duration.timescale)
        }
        return result
    }
}
