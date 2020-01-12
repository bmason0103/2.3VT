//
//  HelperTasks.swift
//  MyVirturalTourist
//
//  Created by Brittany Mason on 11/3/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

class helperTasks {

    
    
    static func downloadPhotos (_ completionHandlerForGETStudentLocation: @escaping ( _ result: PhotosParser?, _ error: NSError?) -> Void) {
        
        //Set perameters
        let parametersForMethod = [
            Constants.FlickrParameters.method : Constants.FlickrParametersvalues.methodSearch,
            Constants.FlickrParameters.api_key : Constants.FlickrParametersvalues.api_keyInput,
            Constants.FlickrParameters.privacy_filter: Constants.FlickrParametersvalues.privacy_filterInput,
            Constants.FlickrParameters.safe_search : Constants.FlickrParametersvalues.safe_searchInput,
            Constants.FlickrParameters.content_type : Constants.FlickrParametersvalues.content_typeInput,
            Constants.FlickrParameters.lat : Constants.Coordinate.latitude,
            Constants.FlickrParameters.lon : Constants.Coordinate.longitude,
            Constants.FlickrParameters.extra : Constants.FlickrParametersvalues.extraInput,
            Constants.FlickrParameters.per_page : Constants.FlickrParametersvalues.per_pageInput,
            Constants.FlickrParameters.format : Constants.FlickrParametersvalues.formatInput,
            Constants.FlickrParameters.nojsoncallback : Constants.FlickrParametersvalues.nojsoncallback,
        
            
            ] as [String : Any]
        
        //2.3 BUILD THE URL AND CONFIG REQUEST
        let requestURL = Constants.MakeURL.flickrbaseURL + Constants.escapedParameters (parametersForMethod as [String:AnyObject])
        
        let _ = methods.taskForGETMethods (urlString:requestURL) { (results, error) in
            
            if let error = error {
                completionHandlerForGETStudentLocation(nil, error)
                
                }
                guard let results = results else {
                    let userInfo = [NSLocalizedDescriptionKey : "Could not retrieve data."]
                    completionHandlerForGETStudentLocation(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: results as! [String: AnyObject], options: .prettyPrinted)
                    // here "jsonData" is the dictionary encoded in JSON data


                    let photosParser = try JSONDecoder().decode(PhotosParser.self, from: jsonData)
                    completionHandlerForGETStudentLocation(photosParser, nil)
                    

                } catch {
                    print("\(#function) error: \(error)")
                    completionHandlerForGETStudentLocation(nil, error as NSError)
                }
            }
        }
        
    }
   
