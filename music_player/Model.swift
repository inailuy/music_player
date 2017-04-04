//
//  Model.swift
//  SpotifyDemo
//
//  Created by inailuy on 9/9/16.
//  Copyright © 2016 yulz. All rights reserved.
//

import Foundation
import UIKit

class Artist:NSObject {
    var name :String!
    var id :String!
    var followers :NSNumber!
    var images = [Image]()
    var link :String!
    var genres :NSArray!
    
    var albums = [Album]()
    var topSongs = [Track]()
    var similarArtists = [Artist]()
    
    override init() {
        //
    }
    
    init(json:NSDictionary) {
        super.init()
        
        name = json.value(forKey: Key.Name.rawValue) as! String
        id = json.value(forKey: Key.ID.rawValue) as! String
        genres = json.value(forKey: Key.Generes.rawValue) as? NSArray
        link = json.value(forKey: Key.HREF.rawValue) as! String
        
        let followerDictionary = json.value(forKey: Key.Followers.rawValue)
        followers = (followerDictionary as AnyObject).value(forKey: Key.Total.rawValue) as! NSNumber
        
        let imageArray = json.value(forKey: Key.Images.rawValue) as! [NSDictionary]
        for obj in imageArray {
            let image = Image(json: obj)
            images.append(image)
        }
    }
    
    func loadAdditionalResources() {
        loadAlbums()
        loadTracks()
        loadSimilarArtist()
    }
    
    func loadAlbums() {
        SpotifyAPI.sharedInstance.getArtistAlbums(id: id, withCompletion:{ albumArray in
            self.albums = albumArray
            //check for duplicates
            for x in 0...albumArray.count {
                var y = x+1
                while self.albums.count > y {
                    if self.albums[x].name == self.albums[y].name {
                        self.albums.remove(at: y)
                        break
                    }
                    y += 1
                }
            }
            
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: NotificationKey.ArtistResultsKey.rawValue), object: nil)
        })
    }
    
    func loadTracks() {
        SpotifyAPI.sharedInstance.getArtistTopTracks(id: id, withCompletion:{ trackArray in
            self.topSongs = trackArray
            
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: NotificationKey.TrackResultsKey.rawValue), object: nil)
        })
    }
    
    func loadSimilarArtist() {
        SpotifyAPI.sharedInstance.getSimilarArtist(id: id, withCompletion:{ artistArray in
            self.similarArtists = artistArray
            
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: NotificationKey.TrackResultsKey.rawValue), object: nil)
        })
    }
    
    func portraitImage() -> Image? {
        for i in images {
            if i.width.floatValue / i.hieght.floatValue > 0.9 &&
                i.width.floatValue / i.hieght.floatValue < 1.1 {
                return i
            }
        }
        if images.count > 0 {
            return images.last
        }
        
        return nil
    }
    
    func followerString() -> String {
        switch followers.intValue {
        case 0...999:
            return String(followers.intValue) + " Followers"
        case 1000...999999:
            let thousand = followers.intValue / 1000
            return String(thousand) + "k Followers"
        case 1000000...999999999:
            let million = followers.intValue / 1000000
            return String(million) + "m Followers"
        default:
            return ""
        }
    }
}

class Album:NSObject {
    var name :String!
    var id :String!
    var artist :String?
    var genres :NSArray?
    var explicit :Bool?
    
    var images = [Image]()
    var tracks = [Track]()
    
    override init() {
        //
    }
    
    init(json: NSDictionary) {
        super.init()
        name = json.value(forKey: Key.Name.rawValue) as! String
        id = json.value(forKey: Key.ID.rawValue) as! String

        let imageArray = json.value(forKey: Key.Images.rawValue) as! [NSDictionary]
        for obj in imageArray {
            let image = Image(json: obj)
            images.append(image)
        }
        
        SpotifyAPI.sharedInstance.getAlbumTracks(id: id, withCompletion:{ trackArray in
            self.tracks = trackArray 
            for track in trackArray {
                if track.explicit.boolValue == true {
                    self.explicit = true
                    break
                }
            }
            
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: NotificationKey.TrackResultsKey.rawValue), object: nil)
        })
    }
    
    func portraitImage() -> Image? {
        for i in images {
            if i.width.floatValue / i.hieght.floatValue > 0.75 &&
                i.width.floatValue / i.hieght.floatValue < 1.2 {
                return i
            }
        }
        return images.first
    }
    
    func backgroundImage() -> Image? {
        for i in images {
            if i.width.floatValue / i.hieght.floatValue > 1.25 {
                return i
            }
        }
        return nil
    }
}

class Track:NSObject {
    var name :String!
    var duration :NSNumber!
    var id :String!
    var explicit :NSNumber
    var previewURL :String?
    var album :Album!
    
    init(json: NSDictionary) {
        //print(json)
        name = json.value(forKey: Key.Name.rawValue) as! String
        id = json.value(forKey: Key.ID.rawValue) as! String
        duration = json.value(forKey: Key.Duration.rawValue) as! NSNumber
        explicit = json.value(forKey: Key.Explicit.rawValue) as! NSNumber
        previewURL = json.value(forKey: Key.PreviewURL.rawValue) as? String
        
        if let albumJSON = json.value(forKey: "album") {
            album = Album(json: albumJSON as! NSDictionary)
        }
    }
    
    func length() -> String {
        let sec = duration.intValue % 60
        let minutes = duration.intValue / 60000
        return String(format: "%02d:%02d", minutes, sec)
    }
}

class Image:NSObject {
    var hieght :NSNumber!
    var width :NSNumber!
    var url :String!
    
    override init() {
        //
    }
    
    init(json: NSDictionary) {
        hieght = json.value(forKey: Key.Height.rawValue) as! NSNumber
        width = json.value(forKey: Key.Width.rawValue) as! NSNumber
        url = json.value(forKey: Key.URL.rawValue) as! String
    }
}

//UIImage Extension
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
