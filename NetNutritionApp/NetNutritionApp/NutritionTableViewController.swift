//
//  NutritionTableViewController.swift
//  NetNutritionApp
//
//  Created by Xiangming Kong on 4/13/22.
//  Modified Alex Slover
//

import UIKit
import RealmSwift
import HealthKit


class nutritionCell: UITableViewCell {
    @IBOutlet weak var nutrient: UILabel!
    @IBOutlet weak var info: UILabel!
}

class NutritionTableViewController: UITableViewController {
    
    
    var currentDate = Date()
    var healthStore : HKHealthStore?
    
    var calsDouble : Double?
    var totalSugarDouble : Double?
    var calciumDouble : Double?
    var cholesteroleDouble : Double?
    var fiberDouble : Double?
    var ironDouble : Double?
    var potassiumDouble : Double?
    var proteinDouble : Double?
    var satFatDouble : Double?
    var sodiumDouble : Double?
    var carbsDouble : Double?
    var totalFatDouble: Double?
    
    
    var foodItemName: String!
    var foodItemId: Int!
    var nutrition: [Dictionary<String, Double>.Element]!
    var location: Location!
    let realm = try! Realm()
    var success = true
    
    @IBAction func logMeal(_ sender: UIButton) { // Log item nutrition to HealthKit and history when "Log Meal Nutrition" button is pressed
        //print("Logged to HealthKit!:")
        //print(nutrition!)
        //print(location.name!)
        print(nutrition!)
        
        calciumDouble = nutrition![1].value
        calsDouble = nutrition![2].value
        cholesteroleDouble = nutrition![3].value
        fiberDouble = nutrition![4].value
        ironDouble = nutrition![5].value
        potassiumDouble = nutrition![6].value
        proteinDouble =  nutrition![7].value
        satFatDouble =  nutrition![8].value
        sodiumDouble =  nutrition![10].value
        carbsDouble =  nutrition![11].value
        totalFatDouble =  nutrition![12].value
        totalSugarDouble =  nutrition![13].value
        
        
        self.saveCalories(date: currentDate, cals: calsDouble!)
        self.saveCalcium(date: currentDate, unit: calciumDouble!)
        self.saveCholesterol(date: currentDate, unit: cholesteroleDouble!)
        self.saveFiber(date: currentDate, unit: fiberDouble!)
        self.saveIron(date: currentDate, unit: ironDouble!)
        self.savePotassium(date: currentDate, unit: potassiumDouble!)
        self.saveProtein(date: currentDate, unit: proteinDouble!)
        self.saveSatFat(date: currentDate, unit: satFatDouble!)
        self.saveSodium(date: currentDate, unit: sodiumDouble!)
        self.saveCarbs(date: currentDate, unit: carbsDouble!)
        self.saveTotalFat(date: currentDate, unit: totalFatDouble!)
        self.saveSugar(date: currentDate, unit: totalSugarDouble!)
        
        
        let date = Date()
        var calendar = Calendar.current

        if let timeZone = TimeZone(identifier: "EST") {
           calendar.timeZone = timeZone
        }
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfTheWeekString = dateFormatter.string(from: date)
        
        let foodInfo = FoodInfo()
        foodInfo.name = foodItemName
        foodInfo.id = String(foodItemId)
        foodInfo.location = location.name
        foodInfo.day = dayOfTheWeekString
        // get the current date and time
        let currentDateTime = Date()

        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short

        // get the date time String from the date object
        foodInfo.time = formatter.string(from: currentDateTime)
        
        // Save to Realm
        try! realm.write {
            realm.add(foodInfo)
            for (key, value) in nutrition {
                foodInfo.nutrition[key] = value
            }
        }
    
        let alert = UIAlertController(title: "Logged!", message: "This meal has been added to HealthKit and Log History.", preferredStyle: .alert)
        
        let continueMeal = UIAlertAction(title: "Continue", style: .default)
        
        alert.addAction(continueMeal)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authorizeHealthKitinApp()
        if nutrition.count == 0 {
            print("Error in getting nutrition data")
            success = false
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return success ? 15 : 1
    }
    
    override func tableView(_ tableView: UITableView,
                                titleForHeaderInSection section: Int) -> String? {
            return "Nutrition Facts"
        }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nutritionCell", for: indexPath) as! nutritionCell
        
        if success {
            cell.nutrient.text = nutrition[indexPath.row].key
            cell.info.text = String(nutrition[indexPath.row].value)
        } else {
            cell.nutrient.text = "Error!"
            cell.info.text = "Could not get nutrition for this item."
        }
        
        //print(nutrition[indexPath.row].key) // Represents the nutrition label like "Calories"
        //print(String(nutrition[indexPath.row].value)) // Represents the nutrition value like 500

        return cell
    }
    
    func authorizeHealthKitinApp() {
        
        
        if HKHealthStore.isHealthDataAvailable(){
            print("healthkit works!")
            healthStore = HKHealthStore()
        }
        
        else{
            print ("healthkit not working")
        }
        


        let calcium = HKQuantityType.quantityType(forIdentifier: .dietaryCalcium)
        let caloriesConsumed = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)
        let cholesterol = HKQuantityType.quantityType(forIdentifier: .dietaryCholesterol)
        let dietaryFiber = HKQuantityType.quantityType(forIdentifier: .dietaryFiber)
        let iron = HKQuantityType.quantityType(forIdentifier: .dietaryIron)
        let potassium = HKQuantityType.quantityType(forIdentifier: .dietaryPotassium)
        let protein = HKQuantityType.quantityType(forIdentifier: .dietaryProtein)
        let saturatedFat = HKQuantityType.quantityType(forIdentifier: .dietaryFatSaturated)
        let sodium = HKQuantityType.quantityType(forIdentifier: .dietarySodium)
        let carbohydrates = HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates)
        let totalFat = HKQuantityType.quantityType(forIdentifier: .dietaryFatTotal)
        let totalSugars = HKQuantityType.quantityType(forIdentifier: .dietarySugar)
        
        
        let healthKitTypesToWrite: Set = [calcium!, caloriesConsumed!,cholesterol!, dietaryFiber!, iron!, potassium!, protein!, saturatedFat!, sodium!, carbohydrates!, totalFat!, totalSugars!]
        
        let healthKitTypestoRead : Set = [caloriesConsumed!]
        
        healthStore?.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypestoRead) {success, error in
            
            if success {
                
                
                print("Successfully requested authorization")
                
                
            }
            
            else {
                print("Failed to request authorization")
            }
        }
    }
    
    
    func saveCalories(date: Date, cals: Double) {
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)
        
        let calories = HKQuantitySample.init(type: quantityType!,
                                                    quantity: HKQuantity.init(unit: HKUnit.largeCalorie(), doubleValue: cals),
                                                    start: date,
                                                    end: date)

        healthStore?.save(calories) { success, error in
                  if (error != nil) {
                      print("Error: \(String(describing: error))")
                  }
                  if success {
                      print("Saved: \(success)")
                  }
        }
}
    
    
    func saveCalcium(date: Date, unit: Double) {
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCalcium)
        
        let calc = HKQuantitySample.init(type: quantityType!,
                                         quantity: HKQuantity.init(unit: HKUnit.gram(), doubleValue: unit/1000),
                                                    start: date,
                                                    end: date)

        healthStore?.save(calc) { success, error in
                  if (error != nil) {
                      print("Error: \(String(describing: error))")
                  }
                  if success {
                      print("Saved: \(success)")
                  }
        }
}
    
    func saveCholesterol(date: Date, unit: Double) {
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCholesterol)
        
        let chol = HKQuantitySample.init(type: quantityType!,
                                         quantity: HKQuantity.init(unit: HKUnit.gram(), doubleValue: unit/1000),
                                                    start: date,
                                                    end: date)

        healthStore?.save(chol) { success, error in
                  if (error != nil) {
                      print("Error: \(String(describing: error))")
                  }
                  if success {
                      print("Saved: \(success)")
                  }
        }
}
    
    func saveIron(date: Date, unit: Double) {
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryIron)
        
        let iron = HKQuantitySample.init(type: quantityType!,
                                         quantity: HKQuantity.init(unit: HKUnit.gram(), doubleValue: unit/1000),
                                                    start: date,
                                                    end: date)

        healthStore?.save(iron) { success, error in
                  if (error != nil) {
                      print("Error: \(String(describing: error))")
                  }
                  if success {
                      print("Saved: \(success)")
                  }
        }
}
 
    
    func savePotassium(date: Date, unit: Double) {
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryPotassium)
        
        let pota = HKQuantitySample.init(type: quantityType!,
                                         quantity: HKQuantity.init(unit: HKUnit.gram(), doubleValue: unit/1000),
                                                    start: date,
                                                    end: date)

        healthStore?.save(pota) { success, error in
                  if (error != nil) {
                      print("Error: \(String(describing: error))")
                  }
                  if success {
                      print("Saved: \(success)")
                  }
        }
}

    
    func saveSodium(date: Date, unit: Double) {
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySodium)
        
        let sodi = HKQuantitySample.init(type: quantityType!,
                                         quantity: HKQuantity.init(unit: HKUnit.gram(), doubleValue: unit/1000),
                                                    start: date,
                                                    end: date)

        healthStore?.save(sodi) { success, error in
                  if (error != nil) {
                      print("Error: \(String(describing: error))")
                  }
                  if success {
                      print("Saved: \(success)")
                  }
        }
}
    
    
    func saveFiber(date: Date, unit: Double) {
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFiber)
        
        let fib = HKQuantitySample.init(type: quantityType!,
                                         quantity: HKQuantity.init(unit: HKUnit.gram(), doubleValue: unit),
                                                    start: date,
                                                    end: date)

        healthStore?.save(fib) { success, error in
                  if (error != nil) {
                      print("Error: \(String(describing: error))")
                  }
                  if success {
                      print("Saved: \(success)")
                  }
        }
}
    
    
    
    func saveProtein(date: Date, unit: Double) {
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryProtein)
        
        let pro = HKQuantitySample.init(type: quantityType!,
                                         quantity: HKQuantity.init(unit: HKUnit.gram(), doubleValue: unit),
                                                    start: date,
                                                    end: date)

        healthStore?.save(pro) { success, error in
                  if (error != nil) {
                      print("Error: \(String(describing: error))")
                  }
                  if success {
                      print("Saved: \(success)")
                  }
        }
}
    
    
    func saveSatFat(date: Date, unit: Double) {
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatSaturated)
        
        let satFat = HKQuantitySample.init(type: quantityType!,
                                         quantity: HKQuantity.init(unit: HKUnit.gram(), doubleValue: unit),
                                                    start: date,
                                                    end: date)

        healthStore?.save(satFat) { success, error in
                  if (error != nil) {
                      print("Error: \(String(describing: error))")
                  }
                  if success {
                      print("Saved: \(success)")
                  }
        }
}
    
    
    func saveCarbs(date: Date, unit: Double) {
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCarbohydrates)
        
        let carbs = HKQuantitySample.init(type: quantityType!,
                                         quantity: HKQuantity.init(unit: HKUnit.gram(), doubleValue: unit),
                                                    start: date,
                                                    end: date)

        healthStore?.save(carbs) { success, error in
                  if (error != nil) {
                      print("Error: \(String(describing: error))")
                  }
                  if success {
                      print("Saved: \(success)")
                  }
        }
}
    
    
    func saveTotalFat(date: Date, unit: Double) {
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryFatTotal)
        
        let totalFat = HKQuantitySample.init(type: quantityType!,
                                         quantity: HKQuantity.init(unit: HKUnit.gram(), doubleValue: unit),
                                                    start: date,
                                                    end: date)

        healthStore?.save(totalFat) { success, error in
                  if (error != nil) {
                      print("Error: \(String(describing: error))")
                  }
                  if success {
                      print("Saved: \(success)")
                  }
        }
}
    
    
    func saveSugar(date: Date, unit: Double) {
        
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietarySugar)
        
        let suga = HKQuantitySample.init(type: quantityType!,
                                         quantity: HKQuantity.init(unit: HKUnit.gram(), doubleValue: unit),
                                                    start: date,
                                                    end: date)

        healthStore?.save(suga) { success, error in
                  if (error != nil) {
                      print("Error: \(String(describing: error))")
                  }
                  if success {
                      print("Saved: \(success)")
                  }
        }
}
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
