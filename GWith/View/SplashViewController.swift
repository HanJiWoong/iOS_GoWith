//
//  SplashViewController.swift
//  GWith
//
//  Created by 한지웅 on 2022/11/14.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.performSegue(withIdentifier: "ShowWebView", sender: self.view)
        }
    }
    
}
