//
//  MapViewController.swift
//  VirtualVacation
//
//  Created by Kirill Kudymov on 2017-04-29.
//  Copyright © 2017 Kirill Kudymov. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    
    // MARK: Properties
    
    var vacationLocations: [VacationLocation] = []
    
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure mapView
        mapView.delegate = self
        
        // Get Core Data stack
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        do {
            vacationLocations = try context.fetch(VacationLocation.fetchRequest())
        } catch {
            print("Annotation fetch failed")
        }
        
        for location in vacationLocations {
            let annotation = MKPointAnnotation()
            
            // locationVacation.latitude can be nil this line can fail
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            annotation.title = location.title
            annotation.subtitle = location.subtitle
            mapView.addAnnotation(annotation)
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func longPressMapViewAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        // If user long press on map view...
        if gestureRecognizer.state == .began {
            
            // convert touch location to the mapView coordinate
            let touchPoint = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            // ... and create annotation at those coordinate
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            
            // find description of the point and add the information to annotation
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)) { placemarks, error in
                guard (error == nil) else {
                    print("Revese geocoding failed with error" + error!.localizedDescription)
                    return
                }
                
                guard let placemarks = placemarks, placemarks.count > 0 else {
                    print("No location was returned")
                    annotation.title = "Unknown Place"
                    self.addVacationLocation(annotation)
                    return
                }
                
                let placemark = placemarks[0]
                annotation.title = placemark.country ?? "Unknown country"
                annotation.subtitle = placemark.locality ?? "Unknown city"
                
                self.addVacationLocation(annotation)
            }
            
        }
    }
    
    
    // Add annotation to mapView and save location to Core Data
    func addVacationLocation(_ annotation: MKPointAnnotation) {
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
            
            // Get context
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            
            // Create and configure vacationLocation
            let vacationLocation = VacationLocation(context: context)
            vacationLocation.title = annotation.title
            vacationLocation.subtitle = annotation.subtitle
            vacationLocation.latitude = annotation.coordinate.latitude
            vacationLocation.longitude = annotation.coordinate.longitude
            vacationLocation.creationDate = Date() as NSDate
            vacationLocation.id = Int32(Date().timeIntervalSince1970)
            
            let photoNames = ["Photo-1", "Photo-2", "Photo-3"]
            
            for photoName in photoNames {

                let image = UIImage(named: photoName)!
                
                guard let imageData = UIImageJPEGRepresentation(image, 1.0) else {
                    print("Image conversion to JPEG failed")
                    return
                }
                
                let thumbnail = image.scale(toSize: self.view.frame.size)
                guard let thumbnailData = UIImageJPEGRepresentation(thumbnail, 0.7) else {
                    print("Thumbnail conversion to JPEG failed")
                    return
                }

                // Create photo
                let photo = Photo(context: context)
                
                // Create and configure image object
                let imageObject = Image(context: context)
                imageObject.fullResolution = imageData as NSData
                imageObject.photo = photo
                
                // Configure photo object
                photo.vacationLocation = vacationLocation
                photo.title = photoName
                photo.image = imageObject
                photo.thumbnail = thumbnailData as NSData
                photo.creationDate = Date() as NSDate
                photo.id = Int32(Date().timeIntervalSince1970)
            }
            print("success?")
        }
    }
    
}


// MARK: - MapView Extension

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped: UIControl) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let albumCollectionViewController = storyboard.instantiateViewController(withIdentifier: "albumCollectionViewController")
        
        present(albumCollectionViewController, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let deqeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            deqeuedView.annotation = annotation
            view = deqeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            let pinColor = UIColor(red: 0.98, green: 0.8549, blue: 0.2, alpha: 1.0)
            view.pinTintColor = pinColor
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton.init(type: .detailDisclosure) as UIView
        }
        
        return view
    }
}


// MARK: - CGSize extension

extension CGSize {
    
    func resizeFill(toSize: CGSize) -> CGSize {
        
        let scale : CGFloat = (self.height / self.width) < (toSize.height / toSize.width) ? (self.height / toSize.height) : (self.width / toSize.width)
        return CGSize(width: (self.width / scale), height: (self.height / scale))
        
    }
}


// MARK: - UIImage extension

extension UIImage {
    
    func scale(toSize newSize:CGSize) -> UIImage {
        
        // make sure the new size has the correct aspect ratio
        let aspectFill = self.size.resizeFill(toSize: newSize)
        
        UIGraphicsBeginImageContextWithOptions(aspectFill, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: aspectFill.width, height: aspectFill.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}
