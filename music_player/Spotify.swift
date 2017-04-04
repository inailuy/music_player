//
//  SpotifyAPI.swift
//
//
//  Copyright © 2017 yulz. All rights reserved.
//

import Foundation

let GET = "GET"
let baseURL = "https://api.spotify.com/v1/"

let user = "yulianii"
let playlistId = "4rBc9pfmPWa8gRYWPUYwd3"

enum EndPoints: String {
    case Artists = "artists"
    case Albums = "albums"
    case Tracks = "tracks"
    case Search = "search"
    case Users = "users"
}

enum Key :String {
    case Name = "name"
    case ID = "id"
    case Generes = "generes"
    case HREF = "href"
    case Followers = "followers"
    case Total = "total"
    case Images = "images"
    case Height = "height"
    case Width = "width"
    case URL = "url"
    case Duration = "duration_ms"
    case Explicit = "explicit"
    case PreviewURL = "preview_url"
    case Artist = "artists"
    case Items = "items"
    case Tracks = "tracks"
}

enum NotificationKey:String {
    case ArtistResultsKey = "artistResultsKey"
    case AlbumResultsKey = "albumResultsKey"
    case TrackResultsKey = "trackResultsKey"
}

class SpotifyAPI: NSObject {
    static let sharedInstance = SpotifyAPI()
    
    //MARK: Basics
    private func createRequest(url: NSURL, method: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    private func createTask(request: NSMutableURLRequest, completion: @escaping (_ json: NSDictionary) -> Void) {
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options:[]) as! NSDictionary
                if let error = json["error"] {
                    print(error)
                    return
                }
                completion(json)
            }
            catch{
                print("create task error")
                print(error)
            }
        }
        task.resume()
    }
    
    func postNotification(key: String, results:AnyObject) {
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: key), object: results)
    }
    
    //MARK: Get Artists
    func getArtists(query: String) {
        let url = SpotifyURL.searchArtist(query: query)
        let request = createRequest(url: url!, method:GET)
        createTask(request: request, completion:{ json in
            let dic = json.value(forKey: Key.Artist.rawValue) as! NSDictionary
            let array = dic.value(forKey: Key.Items.rawValue) as! [NSDictionary]
            var artistArray = [Artist]()
            for obj in array {
                let artist = Artist(json: obj)
                artistArray.append(artist)
            }
            self.postNotification(key: NotificationKey.ArtistResultsKey.rawValue, results: artistArray as AnyObject)
        })
    }
    
    func getArtists(query: String, withCompletion:@escaping (_ albumArray: [Artist]) -> Void) {
        let formartQuery = query.replacingOccurrences(of:" ", with: "+")
        if let url = SpotifyURL.searchArtist(query: formartQuery + "*") {
            let request = createRequest(url: url, method:GET)
            createTask(request: request, completion:{ json in
                let dic = json.value(forKey: Key.Artist.rawValue) as! NSDictionary
                let array = dic.value(forKey: Key.Items.rawValue) as! [NSDictionary]
                var artistArray = [Artist]()
                for obj in array {
                    let artist = Artist(json: obj)
                    artistArray.append(artist)
                }
                withCompletion(artistArray)
            })
        }
    }
    
    func getSimilarArtist(id: String, withCompletion:@escaping (_ albumArray: [Artist]) -> Void) {
        let url = SpotifyURL.getArtistRelatedArtist(id: id)
        let request = createRequest(url: url, method: GET)
        createTask(request: request, completion: { json in
            let array = json.value(forKey: Key.Artist.rawValue) as! [NSDictionary]
            var artistArray = [Artist]()
            for obj in array {
                let artist = Artist(json: obj)
                artistArray.append(artist)
            }
            withCompletion(artistArray)
        })
    }
    
    //MARK: Get Playlist
    func getPlaylist(userId: String, playlistId: String, withCompletion:@escaping (_ albumArray: [Track]) -> Void) {
        let url = SpotifyURL.getPlaylist(userId: userId, playlistId: playlistId)
        let request = createRequest(url: url, method: GET)
        createTask(request: request, completion: { json in
            let array = json.value(forKey: Key.Tracks.rawValue) as! [NSDictionary]
            var albumArray = [Track]()
            for obj in array {
                let track = Track(json: obj)
                albumArray.append(track)
            }
            withCompletion(albumArray)
        })
    }
    
    //MARK: Get Albums
    func getArtistAlbums(id: String, withCompletion:@escaping (_ albumArray: [Album]) -> Void) {
        let url = SpotifyURL.getArtistsAlbums(id: id)
        let request = createRequest(url: url, method: GET)
        createTask(request: request, completion: { json in
            let array = json.value(forKey: Key.Items.rawValue) as! [NSDictionary]
            var albumArray = [Album]()
            for obj in array {
                let album = Album(json: obj)
                albumArray.append(album)
            }

            withCompletion(albumArray)
        })
    }
    
    //MARK: Get Tracks
    func getAlbumTracks(id: String) {
        let url = SpotifyURL.getAlbumsTracks(id: id)
        let request = createRequest(url: url, method: GET)

        createTask(request: request, completion: { json in
            let array = json.value(forKey: Key.Items.rawValue) as! [NSDictionary]
            var trackArray = [Track]()
            for obj in array {
                let track = Track(json: obj)
                trackArray.append(track)
            }
            self.postNotification(key: NotificationKey.TrackResultsKey.rawValue, results: trackArray as AnyObject)
        })
    }
    
    func getAlbumTracks(id: String, withCompletion:@escaping (_ albumArray: [Track]) -> Void) {
        let url = SpotifyURL.getAlbumsTracks(id: id)
        let request = createRequest(url: url, method: GET)
        createTask(request: request, completion: { json in
            let array = json.value(forKey: Key.Items.rawValue) as! [NSDictionary]
            var trackArray = [Track]()
            for obj in array {
                let track = Track(json: obj)
                trackArray.append(track)
            }

            withCompletion(trackArray)
        })
    }
    
    func getArtistTopTracks(id: String) {
        let url = SpotifyURL.getArtistTopTracks(id: id)
        let request = createRequest(url: url, method: GET)
        createTask(request: request, completion: { json in
            let array = json.value(forKey: Key.Tracks.rawValue) as! [NSDictionary]
            var trackArray = [Track]()
            for obj in array {
                let track = Track(json: obj)
                trackArray.append(track)
            }
            self.postNotification(key: NotificationKey.TrackResultsKey.rawValue, results: trackArray as AnyObject)
        })
    }
    
    func getArtistTopTracks(id: String, withCompletion:@escaping (_ albumArray: [Track]) -> Void) {
        let url = SpotifyURL.getArtistTopTracks(id: id)
        let request = createRequest(url: url, method: GET)
        createTask(request: request, completion: { json in
            let array = json.value(forKey: Key.Tracks.rawValue) as! [NSDictionary]
            var trackArray = [Track]()
            for obj in array {
                let track = Track(json: obj)
                trackArray.append(track)
            }
            withCompletion(trackArray)
        })
    }
}

struct SpotifyURL {
    //MARK: Artists URL
    static func getArtist(id: String) -> NSURL {
        let urlString = baseURL + EndPoints.Artists.rawValue + "/" + id
        return NSURL(string: urlString)!
    }
    
    static func getSeveralArtists(id: String) -> NSURL {
        let urlString = baseURL + EndPoints.Artists.rawValue + "?ids=" + id
        return NSURL(string: urlString)!
    }
    
    static func getArtistsAlbums(id: String) -> NSURL {
        let urlString = baseURL + EndPoints.Artists.rawValue + "/" + id + "/albums?album_type=album&market=ES"
        return NSURL(string: urlString)!
    }
    
    static func getArtistTopTracks(id: String) -> NSURL {
        let urlString = baseURL + EndPoints.Artists.rawValue + "/" + id + "/top-tracks?country=US"
        return NSURL(string: urlString)!
    }
    
    static func getArtistRelatedArtist(id: String) -> NSURL {
        let urlString = baseURL + EndPoints.Artists.rawValue + "/" + id + "/related-artists"
        return NSURL(string: urlString)!
    }
    
    //MARK: Playlist URL
    static func getPlaylist(userId: String, playlistId: String) -> NSURL {
        let urlString = baseURL + EndPoints.Users.rawValue + "/" + userId + "/playlists/" + playlistId + "/tracks"
        return NSURL(string: urlString)!
    }
    
    //MARK: Albums URL
    static func getAlbum(id: String) -> NSURL {
        let urlString = baseURL + EndPoints.Albums.rawValue + "/" + id
        return NSURL(string: urlString)!
    }
    
    static func getSeveralAlbums(id: String) -> NSURL {
        let urlString = baseURL + EndPoints.Albums.rawValue + "?ids=" + id
        return NSURL(string: urlString)!
    }
    
    static func getAlbumsTracks(id: String) -> NSURL {
        let urlString = baseURL + EndPoints.Albums.rawValue + "/" + id + "/tracks"
        return NSURL(string: urlString)!
    }
    
    //MARK: Tracks URL
    static func getTrack(id: String) -> NSURL {
        let urlString = baseURL + EndPoints.Tracks.rawValue + "/" + id
        return NSURL(string: urlString)!
    }
    
    static func getSeveralTracks(id: String) -> NSURL {
        let urlString = baseURL + EndPoints.Tracks.rawValue + "?ids=" + id
        return NSURL(string: urlString)!
    }
    
    //MARK: Search URL
    static func searchArtist(query: String) -> NSURL? {
        let q = query.replacingOccurrences(of: "\\", with: "")
        let urlString :String = baseURL + EndPoints.Search.rawValue + "?q=" + q + "&type=artist"
        if let url = NSURL(string: urlString) {
            return url
        }
        return nil
    }
}
