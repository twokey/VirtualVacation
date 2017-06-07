//
//  FlickrClient.swift
//  VirtualVacation
//
//  Created by Kirill Kudymov on 2017-05-31.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import Foundation


class FlickrClient: NSObject {
    
    
    // MARK: Properties
    
    // Shared instance
    static let SharedInstance = FlickrClient()
    
    // Shared session
    var session = URLSession.shared
    
    // MARK: GET Method
    
    func taskForGETMethod(_ parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // 1. Set the parameters
        var parametersWithAPIKey = parameters
        parametersWithAPIKey[Constants.ParameterKeys.APIKey] = Constants.FlickrAPIValues.APIKey as AnyObject
        
        // 2.Build the URL
        let url = flickrURLFromParameters(parametersWithAPIKey, withPathExtension: nil)
        
        // 3. Build the request
        let request = URLRequest(url: url)
        
        // 4. Create task and made the request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ error: String, code: Int) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: code, userInfo: userInfo))
            }
            
            // Was there an error during request?
            guard (error == nil) else {
                sendError("Error with request \(error!)", code: 0)
                return
            }
            
            // Did we get a successful 2xx response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Request returned a status code other than 2xx", code: (response as? HTTPURLResponse)!.statusCode)
                return
            }
            
            // Did we get data in response?
            guard let data = data else {
                sendError("Request returned no data", code: 1)
                return
            }
            
            // 5. Parse the data and 6. use the data in completion handler
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        // 7. Start the request
        task.resume()
        
        return task
    }
    
    
    // MARK: Helpers
    
    // Create a URL from parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.FlickrAPIValues.ApiScheme
        components.host = Constants.FlickrAPIValues.ApiHost
        components.path = Constants.FlickrAPIValues.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // Convert data to JSON object
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Cannot parse the data to JSON"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 2, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }

}
