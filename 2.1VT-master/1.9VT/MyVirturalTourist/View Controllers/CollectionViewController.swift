//
//  CollectionViewController.swift
//  MyVirturalTourist
//
//  Created by Brittany Mason on 11/4/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class collectionViewController : UIViewController {
    
    var latitude = 0.0
    var longitude = 0.0
    var cityName = ""
    var totalPhotosCount = 0
    let columns: CGFloat = 3.0
    let insert: CGFloat = 8.0
    let regionRadius: CLLocationDistance = 8000
    
    var pictureStruct : [PhotoParser]?
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var dataController: CoreDataStack!
    var pin: ThePin?
    var fetchedResultsController: NSFetchedResultsController<Photos>!
    
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    var totalPages: Int? = nil
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    
    
    
    @IBOutlet weak var collectionMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(latitude, "collectionview cord")
        print(longitude)
        collectionMapView.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        centerMapOnLocation(location: initialLocation)
        configureFlowLayout()
//        if pin?.photos?.count == 0 {
////            self.collectionView.reloadData()
//          getPictureForCollectionView ()
//        }
//        getPictureForCollectionView ()
//        self.collectionView.reloadData()
        
        guard let pin = pin else {
            return
        }
        showOnTheMap(pin)
        
        setupFetchedResultControllerWith(pin)
        
//        if let photos = pin.photos, photos.count == 0 {
//            // pin selected has no photos
//            getPictureForCollectionView ()
            //            fetchPhotosFromAPI(pin)
//        }
        
    }
    
    private func showOnTheMap(_ pin: ThePin) {
        
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        let locCoord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        
        collectionMapView.removeAnnotations(collectionMapView.annotations)
        collectionMapView.addAnnotation(annotation)
        collectionMapView.setCenter(locCoord, animated: true)
    }
    
    private func setupFetchedResultControllerWith(_ pin: ThePin) {
        
        let fr = NSFetchRequest<Photos>(entityName: Photos.name)
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "thePin == %@", argumentArray: [pin])
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: CoreDataStack.shared().context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
        
        // Start the fetched results controller
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("\(#function) Error performing initial fetch: \(error)")
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        let locCoord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        
        collectionMapView.setRegion(coordinateRegion, animated: true)
        collectionMapView.addAnnotation(annotation)
    }
    
    func configureFlowLayout() {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let cellSideLength = (collectionView.frame.width/3) - 1
            flowLayout.itemSize = CGSize(width: cellSideLength, height: cellSideLength)
        }
    }
    
    func getPictureForCollectionView () {
        print("'New Collection' button pressed")
        activityIndicatorStart()
        newCollectionButton.isEnabled = false
        
        helperTasks.downloadPhotos { (pictureInfo, error) in
            if let pictureInfo = pictureInfo {
                let totalPhotos = pictureInfo.photos.photo.count
                self.totalPhotosCount = totalPhotos
                self.pictureStruct = pictureInfo.photos.photo
                self.storePhotos(self.pictureStruct!, forPin: self.pin!)
                
                print(totalPhotos)
//                print(pictureInfo.photos.photo)
                
                DispatchQueue.main.async {
                    //                    self.sizeCollectionView()
                    self.collectionView.reloadData()
                    self.configureFlowLayout()
                    self.activityIndicatorStop()
                    self.newCollectionButton.isEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    self.displayAlert(title: "Error", message: "Unable to get student locations.")
                }
                print(error as Any)
            }
        }
        
    }
    
    private func storePhotos(_ photos: [PhotoParser], forPin: ThePin) {
        func showErrorMessage(msg: String) {
            showInfo(withTitle: "Error", withMessage: msg)
        }
        
        for photo in photos {
            DispatchQueue.main.async {
                if let url = photo.url {
                    _ = Photos(title: photo.title, imageUrl: url, forPin: forPin, context: CoreDataStack.shared().context)
                    self.save()
                }
            }
        }
    }
    
    @IBAction func getPhotoButtonPressed(_ sender: Any) {
        print("'New Collection' button pressed")
        activityIndicatorStart()
        newCollectionButton.isEnabled = false
        getPictureForCollectionView ()
        
       
    }
}


extension collectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        collectionView.reloadData()
        collectionView.performBatchUpdates({() -> Void in

            collectionView!.numberOfItems(inSection: 0)
         
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
}



extension collectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.reloadData()
        
        return self.totalPhotosCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        if let pictureStruct = pictureStruct {
            let images = pictureStruct[(indexPath as NSIndexPath).row]
            if let url = images.url {
                do {
                    let data = try Data.init(contentsOf: URL.init(string: url)!)
                    DispatchQueue.main.async {
                        cell.collectionImageViewCell.image = UIImage(data: data) ?? UIImage(named: "temp")
                    }
                }
                catch {
                    print("error")
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           print(indexPath)

           let photoToDelete = fetchedResultsController.object(at: indexPath)
           CoreDataStack.shared().context.delete(photoToDelete)
           save()
       }
}

extension collectionViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // 2
        let identifier = "pin"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView { // 3
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 4
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:
            MKLaunchOptionsDirectionsModeDriving]
        
    }
    
}

extension collectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension collectionViewController {
    func activityIndicatorStart () {
        print("act ind working")
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    func activityIndicatorStop () {
        activityIndicator.stopAnimating()
    }
    
    
}
