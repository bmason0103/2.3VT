//
//  Responses.swift
//  MyVirturalTourist
//
//  Created by Brittany Mason on 11/3/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class APIResponse {
    struct APIPhotoResponse {
        var photos = "photos"
        var photo = "photo"
        var id = "id"
        //returns 48638364042
        var owner = "owner"
        //returns 21057836@N08
        var secret = "secret"
        //returns 216be4731b
        var title = "title"
        //retunrs title michellem
        var ispublic = "1"
        //returns 1
        var page = "1"
        //returns 1
        var pages = "20"
        //returns 20
        var perpage = "20"
        // returns 20
        var total = "391"
        //returns 391
        
        
        init() { }
        
        
        init(dictionary: [String: AnyObject]) {
            if let photosdict = dictionary["photos"] as? String {
                photos = photosdict
            }
            if let photodict = dictionary["photo"] as? String {
                photo = photodict
            }
            if let photodict = dictionary["id"] as? String {
                id = photodict
            }
            if let owners = dictionary["owner"] as? String {
                owner = owners
            }
            if let secrets = dictionary["secret"] as? String {
                secret = secrets
            }
            if let titles = dictionary["title"] as? String {
                title = titles
            }
            if let ispublics = dictionary["ispublic"] as? String {
                ispublic = ispublics
            }
            if let pagedict = dictionary["page"] as? String {
                page = pagedict
            }
            if let pagesdict = dictionary["pages"] as? String {
                pages = pagesdict
            }
            if let perpages = dictionary["perpage"] as? String {
                perpage = perpages
            }
            if let totals = dictionary["total"] as? String {
                total = totals
            }
        }
        static func picturesFromResults(_ results: [[String:AnyObject]]) -> [APIPhotoResponse] {
            
            var picturesFromFlickr = [APIPhotoResponse]()
            
            // iterate through array of dictionaries, each Movie is a dictionary
            for result in results {
                picturesFromFlickr.append(APIPhotoResponse(dictionary: result))
            }
            
            return picturesFromFlickr
            
            
        }
        
    }
    
}



