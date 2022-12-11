//
//  KaraokeDataStore.swift
//  hackathon
//
//  Created by Daniel Jones on 12/11/22.
//

import Foundation
import Alamofire
import SwiftyJSON

class KaraokeDataStore {
    struct Root: Decodable {
        let array: [String]
    }
    
    func loadData(youtubeID: String, completion: @escaping ([String], [KWord], String, Error?) -> Void) {
        let headers: HTTPHeaders = ["Authorization": "token", "content-type": "Application/json"]
        let url = "http://34.95.221.65:5000/karaoke/GlPlfCy1urI/"
//        let url = "http://34.95.221.65:5000/karaoke/\(youtubeID)/"
        
        // 1
        let request = AF.request(url, method: .get, headers: headers)
        // 2sc
        request.responseJSON { response in
            switch response.result {
            case .success:
                let resJSON = JSON(response.value)
                let word_timestamps_str = resJSON["word_timestamps"].stringValue
                let word_timestamps_array = JSON(parseJSON: word_timestamps_str).arrayValue
                let kWords = word_timestamps_array.map { element in
                    let word = element["word"].stringValue
                    let timestamp = element["timestamp"].doubleValue
                    let kWord = KWord(timestamp: timestamp, word: word)
                    return kWord
                }
                let video_id = resJSON["video_id"].stringValue
                //this is for the wav file
                let instrumentalURL = "http://34.95.221.65:5000/audio_files/\(video_id)/"
                let lyric_lines = resJSON["lyric_lines"].arrayValue.map { element in
                    return element.stringValue
                }
                completion(lyric_lines, kWords, instrumentalURL, nil)
            case .failure(let error):
                completion([], [], "", error)
            }
        }
//        request.responseDecodable { (data) in
//            let json = JSON(data.result)
//            print(json)
//        }
        
//        Alamofire.request(url, method: .get, parameters: parameters, headers: headers).validate().responseJSON() { response in
//            switch response.result {
//            case .success:
//                if let value = response.result.value {
//                    let json = JSON(value)
//
//                    // Do what you need to with JSON here!
//                    // The rest is all boiler plate code you'll use for API requests
//
//
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
    }
    
    func postAPICall() {

    }
}
