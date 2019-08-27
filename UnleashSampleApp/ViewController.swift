//
//  ViewController.swift
//  UnleashSampleApp
//
//  Copyright © 2019 Silvercar. All rights reserved.
//

import UIKit
import Unleash

class ViewController: UIViewController {
    //MARK: Properties
    @IBOutlet internal weak var isFeatureEnabled: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let unleash: Unleash = Unleash(appName: "ios-unleash-sample-app",
                                       url: "https://unleash.silvercar.com/api",
                                       refreshInterval: 300000,
                                       strategies: [EnvironmentStrategy()])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isFeatureEnabled?.text = "\(unleash.isEnabled(name: "enable-auth0-in-admin-client"))"
        }
    }
}

class EnvironmentStrategy: Strategy {    
    var name: String {
        return "environment"
    }
    
    func isEnabled(parameters: [String : String]) -> Bool {
        return "QA" == parameters["environment"]
    }
}
