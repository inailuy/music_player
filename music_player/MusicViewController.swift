//
//  ViewController.swift
//  music_player
//
//  Created by yulz on 3/28/17.
//  Copyright © 2017 yulz. All rights reserved.
//

import UIKit
import MediaPlayer

class MusicViewController: UIViewController {
    @IBOutlet weak var backgroundIV: UIImageView!
    @IBOutlet weak var albumCoverIV: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    
    let artistID = "3iOvXCl6edW5Um0fXEBRXy"
    let albumID = "2PXy9USZAoTSdtrxfkPBnl"
    
    var albumTracks = [Track]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SpotifyAPI.sharedInstance.getArtistTopTracks(id: artistID) { (tracks:[Track]) in
            self.albumTracks = tracks
            // load UI
            self.loadRandomSong()
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        
        AudioController.sharedInstance.delegate = self
    }
    
    func remoteControlReceivedWithEvent(event: UIEvent) {
        if event.type == .remoteControl {
            switch (event.subtype) {
            case .remoteControlPlay, .remoteControlPause:
                AudioController.sharedInstance.pauseAudio()
                break
            case .remoteControlNextTrack:
                loadRandomSong()
                break
            case .remoteControlPreviousTrack:
                let previousSong = AudioController.sharedInstance.currentURL
                AudioController.sharedInstance.playPreview(URLString: previousSong!)
                break
            default:
                break
            }
        }
    }

    //MARK: Button Actions
    @IBAction func previousButtonPressed(_ sender: Any) {
        let previousSong = AudioController.sharedInstance.currentURL
        AudioController.sharedInstance.playPreview(URLString: previousSong!)
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        AudioController.sharedInstance.pauseAudio()
    }
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        loadRandomSong()
    }
    
    func loadRandomSong() {
        if albumTracks.count > 0 {
            let index = arc4random_uniform(UInt32(albumTracks.count) - 1)
            let track = albumTracks[Int(index)]
            changeTrack(track: track)
            DispatchQueue.main.async {
                if let urlString = track.album.images.first?.url {
                    self.albumCoverIV.downloadedFrom(url: URL(string: urlString)!)
                    self.backgroundIV.downloadedFrom(url: URL(string: urlString)!)
                }
                self.artistLabel.text = "The xx"
                self.trackLabel.text = track.name
            }
        }
    }
    
    func changeTrack(track:Track) {
        AudioController.sharedInstance.playPreview(URLString: track.previewURL!)
    }
    
    func modifySlider(seconds: Float) {
        if AudioController.sharedInstance.player.rate == 0 {
            return
        }
        
        if seconds < 0.5
        {
            audioSlider.value = 0;
        } else {
            let result = seconds / AudioController.sharedInstance.playableDuration()
            audioSlider.value = Float(result)
            setMediaPlayer(seconds: Int(seconds))
        }
        
    }
    
    func setMediaPlayer(seconds: Int) {
        let albumArtWork = MPMediaItemArtwork(image: albumCoverIV.image!)
        
        let mpic = MPNowPlayingInfoCenter.default()
        mpic.nowPlayingInfo = [MPMediaItemPropertyTitle: trackLabel.text! as String,
        MPMediaItemPropertyArtist: artistLabel.text! as String,
        MPMediaItemPropertyPlaybackDuration: String(AudioController.sharedInstance.playableDuration()),
        MPNowPlayingInfoPropertyElapsedPlaybackTime: seconds,
        MPMediaItemPropertyArtwork:albumArtWork,
        MPNowPlayingInfoPropertyPlaybackRate: 1]
    }

}

