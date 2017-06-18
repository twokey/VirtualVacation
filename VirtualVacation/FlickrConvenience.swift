//
//  FlickrConvenience.swift
//  VirtualVacation
//
//  Created by Kirill Kudymov on 2017-06-01.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation
import MapKit
import UIKit

extension FlickrClient {
    
    func getRandomPicturesURLListFor(_ locationCoordinate: CLLocationCoordinate2D, completionHandler: @escaping (_ photoURLs: [URL]?, _ error: NSError?) -> Void) {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(locationCoordinate),
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.ResultsPerPage
            ] as [String:AnyObject]

        var picturesURLList = [URL]()
        let _ = taskForGETMethod(methodParameters) { (parsedResult, error) in
            
            func sendError(_ error: String, code: Int) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandler(nil, NSError(domain: "taskForGETMethod", code: code, userInfo: userInfo))
            }
            
            guard let stat = parsedResult?[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                sendError("Flickr API returned an error", code: 3)
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult?[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                sendError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult!)", code: 4)
                return
            }
            
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                sendError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)", code: 5)
                return
            }
            
            // pick a random page!
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            print("Number of pages in Flickr result: \(pageLimit)")
            self.getPicturesURLListFor(locationCoordinate, withPageNumber: randomPage, completionHandler: completionHandler)
        }
    }
    
    func getPicturesURLListFor(_ locationCoordinate: CLLocationCoordinate2D, withPageNumber pageNumber: Int, completionHandler: @escaping (_ photoURLs: [URL]?, _ error: NSError?) -> Void) {
        let methodParametersWithPageNumber = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.BoundingBox: bboxString(locationCoordinate),
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Page: pageNumber,
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.ResultsPerPage
            ] as [String:AnyObject]
        
        let _ = taskForGETMethod(methodParametersWithPageNumber) { (parsedResult, error) in
            
            func sendError(_ error: String, code: Int) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandler(nil, NSError(domain: "taskForGETMethod", code: code, userInfo: userInfo))
            }
            
            guard let stat = parsedResult?[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                sendError("Flickr API returned an error", code: 3)
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult?[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                sendError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult!)", code: 4)
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                sendError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)", code: 6)
                return
            }
            
            guard photosArray.count != 0 else {
                sendError("No Photos Found. Search Again.", code: 7)
                return
            }
            
            var photosURLList = [URL]()
            for photo in photosArray {
                /* GUARD: Does our photo have a key for 'url_m'? */
                guard let photoUrlString = photo[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    sendError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photo)", code: 7)
                    return
                }
                
                // if an image exists at the url, set the image and title
                let photoURL = URL(string: photoUrlString)!
                photosURLList.append(photoURL)
            }
            
            completionHandler(photosURLList, nil)
        }
    }
    
    func getPicturesFor(_ indexPath: IndexPath, photo: Photo, handler: @escaping (_ data: Data?, _ image: UIImage?, _ error: Error?) -> Void) {
        
        let url = URL(string: photo.photoLink)
        let request = URLRequest(url: url!)
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async(execute: {
                guard let data = data else {
                    print("Data for photo is not loaded")
                    return handler(nil, nil, error)
                }
                guard let image = UIImage(data: data) else {
                    print("Data cannot be converter into image")
                    return handler(nil, nil, error)
                }
                return handler(data, image, nil)
            })
        }
        task.resume()
    }
    
    private func bboxString(_ locationCoordinate: CLLocationCoordinate2D) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(locationCoordinate.longitude - Constants.FlickrAPIValues.SearchBBoxHalfSide, Constants.FlickrAPIValues.SearchLonRange.0)
        let minimumLat = max(locationCoordinate.latitude - Constants.FlickrAPIValues.SearchBBoxHalfSide, Constants.FlickrAPIValues.SearchLatRange.0)
        let maximumLon = min(locationCoordinate.longitude + Constants.FlickrAPIValues.SearchBBoxHalfSide, Constants.FlickrAPIValues.SearchLonRange.1)
        let maximumLat = min(locationCoordinate.latitude + Constants.FlickrAPIValues.SearchBBoxHalfSide, Constants.FlickrAPIValues.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }

}
