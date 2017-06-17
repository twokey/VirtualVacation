//
//  Constants.swift
//  VirtualVacation
//
//  Created by Kirill Kudymov on 2017-05-31.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation

struct Constants {
    
    
    // MARK: Shared Instance
//    static let sharedInstance = Constants()
    
    
    // MARK: Constants
    
    // API Values
    
    struct FlickrAPIValues {
        static let APIKey = "787b8a0c4f1436d4599a7be8c3b17c2b"
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest/"
        static let SearchBBoxHalfSide = 0.25
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    // Parameter Keys
    
    struct ParameterKeys {
        static let APIKey = "api_key"
    }
    
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "787b8a0c4f1436d4599a7be8c3b17c2b"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let ResultsPerPage = "20"
        static let UseSafeSearch = "1"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }

}
