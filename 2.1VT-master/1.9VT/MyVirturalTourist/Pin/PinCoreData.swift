////
////  PinCoreData.swift
////  MyVirturalTourist
////
////  Created by Brittany Mason on 12/8/19.
////  Copyright © 2019 Udacity. All rights reserved.
////
//
//import Foundation
//import CoreLocation
//import CoreData
//
//struct PinCoreData: PinCoreDataProtocol {
//
//    static let shared: PinCoreData = PinCoreData()
//
//    private init(){
//
//    }
//
//    func createPin(
//        usingContext context: NSManagedObjectContext,
//        withLocation location: String?,
//        andCoordinate coordinate: CLLocationCoordinate2D
//    ) -> ThePin {
//        let pin = ThePin(context: context)
//
//        pin.name = location
//        pin.latitude = coordinate.latitude
//        pin.longitude = coordinate.longitude
//
//        return pin
//
//    }
//
//    func deletePin(pin: ThePin, fromContext context: NSManagedObjectContext) {
//        context.delete(pin)
//
//        do {
//            try context.save()
//        } catch {
//            print("Error deleting pin: \(error)")
//        }
//    }
//}
