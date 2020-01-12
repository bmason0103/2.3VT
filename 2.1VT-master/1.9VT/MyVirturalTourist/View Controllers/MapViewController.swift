//
//  MapViewController.swift
//  MyVirturalTourist
//
//  Created by Brittany Mason on 11/3/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreData


class MapViewController: UIViewController  {
    
    struct Pin {
        let lat: Double
        let long: Double
    }
    
    var dataController: CoreDataStack!
    var fetchedResultsController:NSFetchedResultsController<ThePin>!
    var pinAnnotation: MKPointAnnotation? = nil
    var cityName = ""
    var savedPictures : [PhotoParser]?
    let locationKey: String = "persistedMapRegion"
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    //MARK: Pre-setup
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        loadPersistedMapLocation()
        if let pins = loadAllPins() {
            showPins(pins)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    
    //MARK: Get coordinates from user tap and add pin to map
    
    
    
    @IBAction func longTap(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            
            let point = sender.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            print(coordinate)
            //Now use this coordinate to add annotation on map.
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            //Set title and subtitle if you want
            
            Constants.Coordinate.latitude = coordinate.latitude
            Constants.Coordinate.longitude = coordinate.longitude
            print("This is constant", Constants.Coordinate.longitude)
            
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            geoCoder.reverseGeocodeLocation(location, completionHandler:
                {
                    placemarks, error -> Void in
                    
                    // Place details
                    guard let placeMark = placemarks?.first else { return }
                    
                    // City
                    if let city = placeMark.subAdministrativeArea {
                        print(city)
                        
                        self.cityName = city
                        print(self.cityName)
                        annotation.title = self.cityName
                        let name = placeMark.name ?? "Unknown Area"
                        
                    }
                    
            }
                
            )
            
            Constants.Coordinate.city = cityName
            annotation.subtitle = "subtitle"
            
            
            self.mapView.addAnnotation(annotation)
            _ = ThePin(
                latitude: String(coordinate.latitude),
                longitude: String(coordinate.longitude),
                context: CoreDataStack.shared().context
            )
            save()
            print(Constants.Coordinate.city, "saved name")
            
        }
        
        
    }
    
    
    
    func addPinGesture(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: mapView)
        let locCoord = mapView.convert(location, toCoordinateFrom: mapView)
        
        if sender.state == .began {
            
            pinAnnotation = MKPointAnnotation()
            pinAnnotation!.coordinate = locCoord
            
            print("\(#function) Coordinate: \(locCoord.latitude),\(locCoord.longitude)")
            
            mapView.addAnnotation(pinAnnotation!)
            
        } else if sender.state == .changed {
            pinAnnotation!.coordinate = locCoord
        } else if sender.state == .ended {
            
            _ = ThePin(
                latitude: String(pinAnnotation!.coordinate.latitude),
                longitude: String(pinAnnotation!.coordinate.longitude),
                context: CoreDataStack.shared().context
            )
            save()
            
        }
    }
    
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        setPersistedMapLocation()
    }
    
    func setPersistedMapLocation() {
        let location = [
            "lat":mapView.centerCoordinate.latitude,
            "long":mapView.centerCoordinate.longitude,
            "latDelta":mapView.region.span.latitudeDelta,
            "longDelta":mapView.region.span.longitudeDelta
        ]
        
        UserDefaults.standard.set(location, forKey: locationKey)
    }
    
    func loadPersistedMapLocation() {
        if let mapRegion = UserDefaults.standard.dictionary(forKey: locationKey) {
            
            let locationData = mapRegion as! [String : CLLocationDegrees]
            let center = CLLocationCoordinate2D(latitude: locationData["lat"]!, longitude: locationData["long"]!)
            let span = MKCoordinateSpan(latitudeDelta: locationData["latDelta"]!, longitudeDelta: locationData["longDelta"]!)
            
            mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        }
    }
    
    //MARK: Setting up Fetch request for previously created pins
    fileprivate func setupFetchedResultsControllerPins() {
        let fetchRequest:NSFetchRequest<ThePin> = ThePin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "longitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: "savedPins")
        fetchedResultsController.delegate = (self as! NSFetchedResultsControllerDelegate)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    //MARK: Setting up Fetch request for previously created photo collections
    fileprivate func setupFetchedResultsControllerPhotos() {
        let fetchRequest:NSFetchRequest<Photos> = Photos.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "URL", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.context, sectionNameKeyPath: nil, cacheName: "savedAlbum")
        fetchedResultsController.delegate = (self as! NSFetchedResultsControllerDelegate)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    func fetchPin(_ predicate: NSPredicate, entityName: String, sorting: NSSortDescriptor? = nil) throws -> ThePin? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let pin = (try dataController.context.fetch(fr) as! [ThePin]).first else {
            return nil
        }
        return pin
    }
    
    private func loadAllPins() -> [ThePin]? {
        var pins: [ThePin]?
        do {
            try pins = CoreDataStack.shared().fetchAllPins(entityName: ThePin.name)
        } catch {
            print("\(#function) error:\(error)")
            showInfo(withTitle: "Error", withMessage: "Error while fetching Pin locations: \(error)")
        }
        return pins
    }
    
    private func loadPin(latitude: String, longitude: String) -> ThePin? {
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", latitude, longitude)
        var pin: ThePin?
        do {
            try pin = CoreDataStack.shared().fetchPin(predicate, entityName: ThePin.name)
        } catch {
            print("\(#function) error:\(error)")
            showInfo(withTitle: "Error", withMessage: "Error while fetching location: \(error)")
        }
        return pin
    }
    
    func showPins(_ pins: [ThePin]) {
        for pin in pins where pin.latitude != nil && pin.longitude != nil {
            let annotation = MKPointAnnotation()
            let lat = Double(pin.latitude!)!
            let lon = Double(pin.longitude!)!
            annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
            mapView.addAnnotation(annotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    //MARK: This will be made an IB Action later
    //    func deleteAction(_ sender: Any) {
    //        // delete all photos
    //        for photos in fetchedResultsController.fetchedObjects! {
    //            DataController.shared?.viewContext.delete(photos)
    //        }
    //
    //    }
    
    func savePin(lat: String, long:String) {
        let savedPin = ThePin(context: dataController.context)
        savedPin.latitude = lat
        savedPin.longitude = long
        try? dataController.context.save()
    }
    
    //MARK: Passing coordinates to next Picture view Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "collectionViewSegue" {
            if let collectionVC = segue.destination as? collectionViewController {
                let sender = sender as! ThePin
                collectionVC.latitude = Double(sender.latitude!)!
                collectionVC.longitude = Double(sender.longitude!)!
                collectionVC.pin = sender
                
                
            }
        }
    }
    
    
    
}
//MARK: MKMapViewDelegate
//*********************************************//
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            //Add code in here about transitioning to other view
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else {
            return
        }
        
        mapView.deselectAnnotation(annotation, animated: true)
        print("\(#function) lat \(annotation.coordinate.latitude) lon \(annotation.coordinate.longitude)")
        let lat = annotation.coordinate.latitude
        let lon = annotation.coordinate.longitude
        if let pin = loadPin(latitude:String(lat),longitude:String(lon)) {
            if isEditing {
                mapView.removeAnnotation(annotation)
                CoreDataStack.shared().context.delete(pin)
                save()
                return
            }
            
            performSegue(withIdentifier: "collectionViewSegue", sender: pin)
        }
    }
}
