//
//  LocationsTableViewDetail.swift
//  NetNutritionApp
//
//  Created by Henry Huynh on 4/6/22.
//

import Foundation
import UIKit



class LocationsTableViewDetail: UIViewController {
    
    @IBOutlet weak var myImage: UIImageView!
    var selectedLocation : Location!
    var menu: [String: [[String: Any]]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myImage.image = UIImage(named: selectedLocation.imageName)
    }
}
