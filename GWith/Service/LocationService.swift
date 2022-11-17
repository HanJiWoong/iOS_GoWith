//
//  LocationService.swift
//  GWith
//
//  Created by 한지웅 on 2022/11/17.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate {
    func updateCurrentLocation(updateLocation:CLLocation)
}

class LocationService:NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    var locationManager:CLLocationManager!
    var delegate:LocationServiceDelegate? = nil
    
    private override init() {
        super.init()
        
        if(CLLocationManager.locationServicesEnabled()) {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.updateCurrentLocation(updateLocation: locations.last! as CLLocation)
    }
}
