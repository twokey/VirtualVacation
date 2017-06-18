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

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    
    // MARK: Properties
    
    // Dictionary with initial region of the map loaded from User Defaults
    lazy var mapViewRegionDictionary: [String : Double] = {
       return UserDefaults.standard.dictionary(forKey: "mapViewRegion") as! [String : Double]
    }()
    
    // Initialize initial region of the map
    lazy var mapViewRegion: MKCoordinateRegion = {
        let center = CLLocationCoordinate2DMake(self.mapViewRegionDictionary["center_latitude"]!, self.mapViewRegionDictionary["center_longitude"]!)
        let span = MKCoordinateSpan(latitudeDelta: self.mapViewRegionDictionary["latitude_delta"]!, longitudeDelta: self.mapViewRegionDictionary["longitude_delta"]!)
        return MKCoordinateRegion(center: center, span: span)
    }()
    
    var sharedContext = CoreDataStack.sharedInstance.persistentContainer.viewContext
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<VacationLocation> = {
        
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<VacationLocation> = VacationLocation.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = []
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        // Start the Fetched Results Controller
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error performing initial fetch: \(error)")
        }
        
        return fetchedResultsController
    }()
    
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure mapView
        title = "Virtual Tourist"
        mapView.delegate = self
        mapView.setRegion(mapViewRegion, animated: true)
        
        for location in fetchedResultsController.fetchedObjects! {
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
        
        // If user tap long on the map view...
        if gestureRecognizer.state == .began {
            
            // convert touch location to the mapView coordinate
            let touchPoint = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            // ... and create annotation at those coordinate
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            
            // Add annotation to the mapView
            self.mapView.addAnnotation(annotation)
            
            // Add description of the annotation
            updateAnnotationDetails(annotation)
            
        }
    }
    
    
    // Create entity for the location and and save the location to Core Data
    func addVacationLocation(_ annotation: MKPointAnnotation) {
        
            // Create and configure vacationLocation
            let vacationLocation = VacationLocation(context: self.sharedContext)
            vacationLocation.title = annotation.title
            vacationLocation.subtitle = annotation.subtitle
            vacationLocation.latitude = annotation.coordinate.latitude
            vacationLocation.longitude = annotation.coordinate.longitude
            vacationLocation.creationDate = Date() as NSDate
            vacationLocation.id = Int32(Date().timeIntervalSince1970)

            CoreDataStack.sharedInstance.saveContext()
        
        createPhotoAlbumFor(vacationLocation)
    }
    
    // Download geo information for a pin and populate the pin with the information
    
    func updateAnnotationDetails(_ annotation: MKPointAnnotation) {
        
        // Download geo information
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)) { placemarks, error in
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
            annotation.title = placemark.locality ?? "Unknown city"
            annotation.subtitle = placemark.country ?? "Unknown country"
            
            // Save location to Core Data
            self.addVacationLocation(annotation)
        }
    }
    
    
    // Download information about Photos at specific location and save it
    
    func createPhotoAlbumFor(_ vacationLocation: VacationLocation) {
        
        let locationCoordinate = CLLocationCoordinate2D(latitude: vacationLocation.latitude, longitude: vacationLocation.longitude)
        
        FlickrClient.SharedInstance.getRandomPicturesURLListFor(locationCoordinate) { (photoURLsDownloaded, error) in
            
            guard let photoURLs = photoURLsDownloaded, photoURLs.count > 0  else {
                print("No photo URL was downloaded")
                return
            }
            
            DispatchQueue.main.async {
                // Download pictures from urls array and populate Core Data table
                for photoURL in photoURLs {
                    
                    // Create photo and image objects
       //             let imageObject = Image(imageData: nil, context: self.sharedContext)
                    let _ = Photo(vacationLocation: vacationLocation, title: "No title", photoLink: photoURL.absoluteString, thumbnail: nil, latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude, context: self.sharedContext)

                }
            
                CoreDataStack.sharedInstance.saveContext()
            }
        }
    }
}


// MARK: - MapView Delegate

extension MapViewController: MKMapViewDelegate {
    
    // Implement if an annotation view was tapped
    
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped: UIControl) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let albumCollectionViewController = storyboard.instantiateViewController(withIdentifier: "albumCollectionViewController") as! PicturesCollectionViewController

        let latitude = annotationView.annotation?.coordinate.latitude
        let longitude = annotationView.annotation?.coordinate.longitude
        albumCollectionViewController.locationCoordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        
        self.navigationController?.pushViewController(albumCollectionViewController, animated: true)        
    }
    
    // Create annotation view for a pin on the map
    
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
    
    // Save new region into defaults if the map was moved/zoomed
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        mapViewRegionDictionary = ["center_latitude" : mapView.region.center.latitude,
                                       "center_longitude" : mapView.region.center.longitude,
                                       "latitude_delta" : mapView.region.span.latitudeDelta,
                                       "longitude_delta" : mapView.region.span.longitudeDelta]
        
        UserDefaults.standard.set(mapViewRegionDictionary, forKey: "mapViewRegion")
        
    }
}

