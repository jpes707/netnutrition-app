//
//  LogViewController.swift
//  NetNutritionApp
//
//  Created by Henry Huynh on 4/16/22.
//

import UIKit
import RealmSwift

class logCell: UITableViewCell {
    
    
    @IBOutlet weak var foodLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
}

class LogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let nutritionTVC = NutritionTableViewController()
    var processNutrition = [String: Double]()
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var table: UITableView!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.center = self.view.center
        table.delegate = self
        table.dataSource = self
        
        let count = realm.objects(FoodInfo.self).count
        if (count > 0) {
            self.label.isHidden = true
            self.table.isHidden = false
        }
        else {
            self.label.isHidden = false
            self.table.isHidden = true
        }
        
        print(Realm.Configuration.defaultConfiguration.fileURL as Any)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let count = realm.objects(FoodInfo.self).count
        if (count > 0) {
            self.label.isHidden = true
            self.table.isHidden = false
        }
        else {
            self.label.isHidden = false
            self.table.isHidden = true
        }
        table.reloadData()
        }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realm.objects(FoodInfo.self).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! logCell
        let foodObject = realm.objects(FoodInfo.self).sorted(byKeyPath: "date", ascending: false)[indexPath.row]
        cell.foodLabel?.text = foodObject.name! + " at " + foodObject.location!
        cell.timeLabel?.text = foodObject.day! + ", " + foodObject.time!
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "logDetail") as? DetailLogTableViewController else {
//            return
//        }
//        vc.title = "Nutrition Info"
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            // Add part here removing it from realm too
        }
    }
  


    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! DetailLogTableViewController
        
        let indexPath = table.indexPathForSelectedRow!
        
        let foodObject = realm.objects(FoodInfo.self).sorted(byKeyPath: "date", ascending: false)[indexPath.row]
//        let id = Int(foodObject.id!)
//        print("id statement")
//        print(id)
        for element in foodObject.nutrition {
            processNutrition[element.key] = element.value
        }
        let sortedNutrition = Array(processNutrition.sorted(by: {$0.0 < $1.0}))
        
        destVC.nutrition = sortedNutrition
        self.table.deselectRow(at: indexPath, animated: true)
    }

}
