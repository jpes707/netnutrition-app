//
//  MealTableViewController.swift
//  NetNutritionApp
//
//  Created by Johnny Pesavento on 4/15/22.
//

import UIKit

class mealsCell: UITableViewCell {
    @IBOutlet weak var meal: UILabel!
    
}

class MealTableViewController: UITableViewController {
    @IBOutlet var mealsTableView: UITableView!
    
    var meals: [Dictionary<String, Int>.Element]!
    var selectedLocation: Location!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return meals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealsCell", for: indexPath) as! mealsCell

        cell.meal.text = meals[indexPath.row].key

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "restaurantDetailSegue") {
            let indexPath = self.mealsTableView.indexPathForSelectedRow!
            let tableViewDetail = segue.destination as? RestaurantTableViewController
            tableViewDetail!.selectedLocation = selectedLocation
            tableViewDetail!.menu = getMenu(restaurant: selectedLocation.name, mealCode: meals[indexPath.row].value)
            self.mealsTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func getMenu(restaurant: String, mealCode: Int) -> [String: [[String: Any]]] {
        let session = URLSession.shared
        let url = URL(string: mealCode == 0 ? "https://netnutrition.cbord.com/nn-prod/duke/Unit/SelectUnitFromSideBar" : "https://netnutrition.cbord.com/nn-prod/duke/Menu/SelectMenu")!
        var url_request = URLRequest(url: url)
        url_request.httpMethod = "POST"
        if mealCode == 0 {
            url_request.httpBody = Data(String(format: "unitOid=%d", restaurantCodes[restaurant]!).utf8)
        } else {
            url_request.httpBody = Data(String(format: "menuOid=%d", mealCode).utf8)
        }
        
        var restaurantDict: [String: [[String: Any]]] = [:]
        let sem = DispatchSemaphore(value: 0)
        let task = session.dataTask(with: url_request, completionHandler: { data, response, error in
            if let data = data, let dataString = String(data: data, encoding: .utf8)?.decodingUnicodeCharacters {
                let range = NSRange(location: 0, length: dataString.utf16.count)
                var indices: [Int] = []
                var names: [String] = []
                
                // regex match all food categories from the webpage
                let regexCategories = try! NSRegularExpression(pattern: #"<div role='button'>([0-9A-Za-z &-']*)<"#)
                let matchesCategories = regexCategories.matches(
                    in: dataString,
                    options: [],
                    range: range
                )
                for match in matchesCategories {
                    for rangeIndex in 1..<match.numberOfRanges {
                        let matchRange = match.range(at: rangeIndex)
                        
                        // Extract the substring matching the capture group
                        if let substringRange = Range(matchRange, in: dataString) {
                            let capture = String(dataString[substringRange])
                            indices.append(matchRange.location)
                            names.append(capture)
                        }
                    }
                }
                indices.append(dataString.count)
                
                // regex match all food items from the webpage
                let regexItems = try! NSRegularExpression(pattern: #"getItemNutritionLabelFromKeyUp.*?(\d+?)\).*?>(.*?)<"#)
                let matchesItems = regexItems.matches(
                    in: dataString,
                    options: [],
                    range: range
                )
                var currentIndex = 0
                var currentArr: [[String: Any]] = []
                for match in matchesItems {
                    
                    var newDict: [String: Any] = [:]
                    for rangeIndex in 1..<match.numberOfRanges {
                        let matchRange = match.range(at: rangeIndex)
                        
                        while matchRange.location > indices[currentIndex + 1] {
                            let key = names[currentIndex]
                            restaurantDict[key] = currentArr
                            currentIndex += 1
                            currentArr = []
                        }
                        
                        // Extract the substring matching the capture group
                        if let substringRange = Range(matchRange, in: dataString) {
                            let capture = String(dataString[substringRange])
                            
                            if rangeIndex == 1 {
                                newDict["id"] = Int(capture)
                                // self.getItemNutrition(itemId: newDict["id"] as! Int)
                            } else {
                                newDict["name"] = capture.replacingOccurrences(of: "\\", with: "")
                            }
                        }
                    }
                    currentArr.append(newDict)
                }
                restaurantDict[names[currentIndex]] = currentArr
                print(restaurantDict)
                sem.signal()
            }
        })
        task.resume()
        sem.wait()
        return restaurantDict
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
