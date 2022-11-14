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

        let startTimer = Timer.scheduledTimer(withTimeInterval: 3000, repeats: false) { timer in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ShowWebView", sender: self.view)
            }
        }
        startTimer.fire()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
