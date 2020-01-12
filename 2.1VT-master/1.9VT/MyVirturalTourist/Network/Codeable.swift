//
//  Codeable.swift
//  MyVirturalTourist
//
//  Created by Brittany Mason on 11/10/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct PhotosParser: Codable {
    let photos: JsonPhotos
}

struct JsonPhotos: Codable {
    let pages: Int
    let photo: [PhotoParser]
}

struct PhotoParser: Codable {
    
    let url: String?
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_m"
        case title = "title"
    }
}
