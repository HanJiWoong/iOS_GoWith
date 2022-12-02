//
//  SplashViewController.swift
//  GWith
//
//  Created by 한지웅 on 2022/11/14.
//

import UIKit
import CoreLocation

class SplashViewController: UIViewController {

    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.performSegue(withIdentifier: "ShowWebView", sender: self.view)
        }
    }
    
}

extension SplashViewController:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied) {
            print("location service denied")
        } else {
            print("location service allow")
        }
    }
}
