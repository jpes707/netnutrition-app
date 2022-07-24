//
//  MenuTableViewController.swift
//  NetNutritionApp
//
//  Created by Xiangming Kong on 4/12/22.
//

import UIKit

class mealCell: UITableViewCell {
    
    @IBOutlet weak var mealItem: UILabel!
    
}

class RestaurantTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet var menuTableView: UITableView!
    
    let searchController = UISearchController()
    var menu: [String: [[String: Any]]]!
    var foodList = [FoodItem]()
    var filteredFoods = [FoodItem]()
    var selectedLocation: Location!
    
    var tempCount : Int {
        menu.count
    }

    var keysArray = [String]()
    var allItems = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSearchController()
        initList()
    }
    
    func initSearchController() {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        definesPresentationContext = true

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
}

    // MARK: - Table view data source

    
    func initList() {
        var setList = Set<String>()
        print(menu)
        for (_, itemList) in menu {
                    for item in itemList {
                        if (!setList.contains(item["name"] as! String)) {
                            foodList.append(FoodItem(name: item["name"] as! String, id: item["id"] as! Int))
                            setList.insert(item["name"] as! String)
                        }
                        
                    }
            
                }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (searchController.isActive) {
            return 1
        }
        return tempCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var arraySize = 0
        
        if (searchController.isActive) {
            arraySize = filteredFoods.count
        }
        else {
            for (i, _) in menu {
                keysArray.append(i)
            }
            
           
            
            for i in 0...keysArray.count {
                if (section == i){
                    arraySize = menu[keysArray[i]]!.count
                }
            }
        }
        
        
        return arraySize
    }
    
    override func tableView(_ tableView: UITableView,
                                titleForHeaderInSection section: Int) -> String? {
            //returns names of sections
        if (searchController.isActive) {
            return "Filtered items"
        }
            return keysArray[section]
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath) as! mealCell

        
        if (searchController.isActive) {
            cell.mealItem.text = filteredFoods[indexPath.row].name
        }
    
        else {
            cell.mealItem.text = menu[keysArray[indexPath.section]]![indexPath.row]["name"] as? String
        }

        return cell
    }
    
    // MARK: - Search Bar Filter
    
    func updateSearchResults(for searchController: UISearchController)
        {
            let searchBar = searchController.searchBar
            let searchText = searchBar.text!
            
            filterForSearchText(searchText: searchText)
        }
        
        func filterForSearchText(searchText: String, scopeButton : String = "All")
        {
            filteredFoods = foodList.filter
            {
                food in
                let scopeMatch = (scopeButton == "All" || food.name.lowercased().contains(scopeButton.lowercased()))
                if(searchController.searchBar.text != "")
                {
                    let searchTextMatch = food.name.lowercased().contains(searchText.lowercased())
                    
                    return scopeMatch && searchTextMatch
                }
                else
                {
                    return scopeMatch
                }
            }
            menuTableView.reloadData()
        }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! NutritionTableViewController
        
        let indexPath = tableView.indexPathForSelectedRow!
        
        var sortedNutrition = Array(getItemNutrition(itemId: menu[keysArray[indexPath.section]]![indexPath.row]["id"] as! Int).sorted(by: {$0.0 < $1.0}))
        destVC.foodItemName = menu[keysArray[indexPath.section]]![indexPath.row]["name"] as? String
        destVC.foodItemId = menu[keysArray[indexPath.section]]![indexPath.row]["id"] as? Int
        if (searchController.isActive) {
            sortedNutrition = Array(getItemNutrition(itemId: filteredFoods[indexPath.row].id).sorted(by: {$0.0 < $1.0}))
            destVC.foodItemName = filteredFoods[indexPath.row].name
            destVC.foodItemId = filteredFoods[indexPath.row].id
            
        }
        //print(sortedNutrition)
        destVC.nutrition = sortedNutrition
        destVC.location = selectedLocation
        
        
        //destVC.nutrition = sortedNutrition
        self.menuTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getItemNutrition(itemId: Int) -> [String: Double] {
        print("getting nutrition")
        let session = URLSession.shared
        let url = URL(string: "https://netnutrition.cbord.com/nn-prod/duke/NutritionDetail/ShowItemNutritionLabel")!
        var url_request = URLRequest(url: url)
        url_request.httpMethod = "POST"
        let s = String(format: "detailOid=%d", itemId).utf8
        url_request.httpBody = Data(s)
        
        let sem = DispatchSemaphore(value: 0)
        var nutrition = [String: Double]()
        let task = session.dataTask(with: url_request, completionHandler: { data, response, error in
            if let data = data, let dataString = String(data: data, encoding: .utf8)?.decodingUnicodeCharacters {
                let range = NSRange(location: 0, length: dataString.count)
                print(dataString)
                let regex = try! NSRegularExpression(pattern: #"inline-div-left.*?>([A-Za-z0-9 \.]+?)<.*?( '>|&nbsp;)(.*?)<.*?<\/td>"#)
                let matches = regex.matches(
                    in: dataString,
                    options: [],
                    range: range
                )
                for match in matches {
                    var key = ""
                    var val = 0.0
                    for rangeIndex in 1..<match.numberOfRanges {
                        if rangeIndex == 2 {
                            continue
                        }
                        let matchRange = match.range(at: rangeIndex)
                                
                        // Extract the substring matching the capture group
                        if let substringRange = Range(matchRange, in: dataString) {
                            let capture = String(dataString[substringRange])
                            print(itemId)
                            print(capture)
                            if rangeIndex == 1 {
                                switch capture {
                                case "Serving Size": key = "Serving Size (g)"
                                case "Amount Per Serving": key = "Calories"
                                case "Total Fat": key = "Total Fat (g)"
                                case "Saturated Fat": key = "Saturated Fat (g)"
                                case "Trans": key = "Trans Fat (g)"
                                case "Cholesterol": key = "Cholesterol (mg)"
                                case "Sodium": key = "Sodium (mg)"
                                case "Total Carbohydrate": key = "Total Carbohydrate (g)"
                                case "Dietary Fiber": key = "Dietary Fiber (g)"
                                case "Total Sugars": key = "Total Sugars (g)"
                                case "Protein": key = "Protein (g)"
                                case "Calcium": key = "Calcium (mg)"
                                case "Iron": key = "Iron (mg)"
                                case "Potas.": key = "Potassium (mg)"
                                default:
                                    key = "Added Sugars (g)"
                                    let rangeInner = NSRange(location: 0, length: capture.count)
                                    let regexInner = try! NSRegularExpression(pattern: #".*?(NA|[0-9.]+).*"#)
                                    let matchesInner = regexInner.matches(
                                        in: capture,
                                        options: [],
                                        range: rangeInner
                                    )
                                    for matchInner in matchesInner {
                                        for rangeIndexInner in 1..<matchInner.numberOfRanges {
                                            let matchRangeInner = matchInner.range(at: rangeIndexInner)
                                            if let substringRangeInner = Range(matchRangeInner, in: capture) {
                                                let captureInner = String(capture[substringRangeInner])
                                                if captureInner != "NA" {
                                                    val = Double(captureInner)!
                                                }
                                            }
                                        }
                                    }
                                    break
                                }
                            } else {
                                let rangeInner = NSRange(location: 0, length: capture.count)
                                let regexInner = try! NSRegularExpression(pattern: #".*?(NA|[0-9.]+).*"#)
                                let matchesInner = regexInner.matches(
                                    in: capture,
                                    options: [],
                                    range: rangeInner
                                )
                                for matchInner in matchesInner {
                                    for rangeIndexInner in 1..<matchInner.numberOfRanges {
                                        let matchRangeInner = matchInner.range(at: rangeIndexInner)
                                        if let substringRangeInner = Range(matchRangeInner, in: capture) {
                                            let captureInner = String(capture[substringRangeInner])
                                            if captureInner != "NA" {
                                                val = Double(captureInner)!
                                            }
                                        }
                                    }
                                }
                            }
                            //print(capture)
                        }
                    }
                    nutrition[key] = val
                }
                if nutrition.count != 15 {
                    //print("ALERT")
                    //print(itemId)
                }
                //print(nutrition)
                sem.signal()
            }
        })
        task.resume()
        sem.wait()
        return nutrition
    }

}
