//
//  ViewController.swift
//  NetNutritionApp
//
//  Created by Johnny Pesavento on 3/22/22.
//

import UIKit
import HealthKit
import RealmSwift

class ViewController: UIViewController {
    
    var healthStore : HKHealthStore?

    override func viewDidLoad() {
        
        if HKHealthStore.isHealthDataAvailable(){
            print("healthkit works!")
            healthStore = HKHealthStore()
        }
        
        else{
            print ("healthkit broke")
        }
    
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
}
