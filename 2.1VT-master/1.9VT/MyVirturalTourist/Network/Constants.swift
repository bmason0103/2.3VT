//
//  Constants.swift
//  MyVirturalTourist
//
//  Created by Brittany Mason on 11/3/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Constants:  UIViewController   {
    
    struct MakeURL {
        static let flickrbaseURL =  "https://www.flickr.com/services/rest/"
       
    }
    
    struct FlickrParameters {
        static let method = "method"
        static let api_key = "api_key"
        static let privacy_filter = "privacy_filter"
        static let safe_search = "safe_search"
        static let content_type = "content_type"
        static let lat = "lat"
        static let lon = "lon"
        static let extra = "extras"
        static let per_page = "per_page"
        static let format = "format"
        static let nojsoncallback = "nojsoncallback"
        
        static let response = "results"
        static var APIResults =    [APIResponse.APIPhotoResponse]()
        
        
    }
    
    struct FlickrParametersvalues {
        static let methodSearch = "flickr.photos.search"
        static let api_keyInput = "ddfe1c6dd17de2ebe8e75735f64d52a7"
        static let privacy_filterInput = "1"
        static let safe_searchInput = "1"
        static let content_typeInput = "1"
        static let lat = 0.0
        static let lon = 0.0
        static let extraInput = "url_m"
        static let per_pageInput = "20"
        static let formatInput = "json"
        static let nojsoncallback = "1"
        
        static let responseInput = "results"
        static var results = "photos"
        static var photo = "photo"
        static let APIResults =    [APIResponse.APIPhotoResponse]()
        
        
    }
    
    
    
    struct Coordinate {
        static var latitude = 0.0
        static var longitude = 0.0
        static var city = "city"
    }
    
    static func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
        
    }
    
    
}

