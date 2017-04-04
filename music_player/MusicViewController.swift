//
//  ViewController.swift
//  music_player
//
//  Created by yulz on 3/28/17.
//  Copyright © 2017 yulz. All rights reserved.
//

import UIKit

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
        
        AudioController.sharedInstance.delegate = self
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        }
        
    }

}
