//
//  LocationsTableViewController.swift
//  NetNutritionApp
//
//  Created by Henry Huynh on 4/6/22.
//

import UIKit

extension String {
    var decodingUnicodeCharacters: String { applyingTransform(.init("Hex-Any"), reverse: false) ?? "" }
    func indexOf(sub: String) -> Int {
        if let range: Range<String.Index> = range(of: sub) {
            let index: Int = distance(from: startIndex, to: range.lowerBound)
            return index
        }
        else {
            return -1
        }
    }
}

let restaurantCodes = [
    "Bella Union": 5,
    "Ginger and Soy": 24,
    "Gyotaku": 25,
    "Il Forno": 22,
    "JB's": 6,
    "Nasher": 19,
    "Panda": 16,
    "Red Mango": 20,
    "Sazon": 23,
    "Krafthouse": 29,
    "The Loop": 17,
    "Farmstead": 11,
    "Tandoor": 21,
    "Beyu Blue": 26,
    "CaFe": 13,
    "Cafe 300": 28,
    "Marketplace": 3,
    "McDonald's": 18,
    "Panera": 30,
    "Saladalia": 14,
    "Sprout": 10,
    "Pitchfork's": 7,
    "Skillet": 8,
    "Trinity Cafe": 4,
    "Zweli's": 31
]
let varietyRestaurants = ["Beyu Blue", "CaFe", "Cafe 300", "Marketplace", "McDonald's", "Panera", "Saladalia", "Sprout", "Pitchfork's", "Skillet", "Zweli's"] // restaurants with specific menus for different meals
let oneMealRestaurants = ["Tandoor", "Farmstead", "Trinity Cafe"] // restaurants with a single, different menu each day


class Redirect : NSObject {
    var session: URLSession?
    
    override init() {
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
    func makeRequest() {
        let url = URL(string: "https://netnutrition.cbord.com/nn-prod/duke")!
        let task = session?.dataTask(with: url) {(data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("Initialized cookie: " + response.allHeaderFields["Set-Cookie"].debugDescription.prefix(51).suffix(24))
            }
        }
        task?.resume()
    }
}

extension Redirect: URLSessionDelegate, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        // Stops the redirection, and returns (internally) the response body.
        completionHandler(nil)
    }
}

class LocationsCustomCell: UITableViewCell {
    
    
    
    @IBOutlet weak var myImage: UIImageView!
    
    @IBOutlet weak var myLabel: UILabel!
    
    
}

class LocationsTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    
    
    
    let searchController = UISearchController()
    
    
    
    @IBOutlet var locationTableView: UITableView!
    
    var locationList = [Location]()
    var filteredLocations = [Location]()
    
    
    
    override func viewDidLoad() {
        let r = Redirect()
        r.makeRequest()
        
        super.viewDidLoad()
        initList()
        initSearchController()
       

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
    
    func initList() {
        for (restaurant, restaurantCode) in Array(restaurantCodes.sorted(by: {$0.0 < $1.0})) {
            //if !varietyRestaurants.contains(restaurant) { // remove later
                locationList.append(Location(name: restaurant, imageName: restaurant.lowercased().replacingOccurrences(of: "'", with: "").replacingOccurrences(of: " ", with: "")))
            //}
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (searchController.isActive) {
            return filteredLocations.count
        }
        return locationList.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! LocationsCustomCell

        
        let thisLocation: Location!
        
        if(searchController.isActive) {
            thisLocation = filteredLocations[indexPath.row]
        }
        else {
            thisLocation = locationList[indexPath.row]
        }
       
        
        cell.myLabel.text = thisLocation.name
        
        cell.myImage.image = UIImage(named: thisLocation.imageName)
        
       
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if varietyRestaurants.contains(locationList[indexPath.row].name) {
            let destinationVCObject = self.storyboard?.instantiateViewController(withIdentifier: "MealTableViewController") as! MealTableViewController
            let selectedLocation = searchController.isActive ? filteredLocations[indexPath.row] : locationList[indexPath.row]
            destinationVCObject.selectedLocation = selectedLocation
            destinationVCObject.meals = Array(getMealsDynamic(restaurant: selectedLocation.name).sorted(by: {$0.0 < $1.0}))
            self.navigationController?.pushViewController(destinationVCObject, animated: true)
        } else {
            let destinationVCObject = self.storyboard?.instantiateViewController(withIdentifier: "RestaurantTableViewController") as! RestaurantTableViewController
            let selectedLocation = searchController.isActive ? filteredLocations[indexPath.row] : locationList[indexPath.row]
            destinationVCObject.selectedLocation = selectedLocation
            destinationVCObject.menu = getMealsFixed(restaurant: selectedLocation.name)
            self.navigationController?.pushViewController(destinationVCObject, animated: true)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController)
        {
            let searchBar = searchController.searchBar
            let searchText = searchBar.text!
            
            filterForSearchText(searchText: searchText)
        }
        
        func filterForSearchText(searchText: String, scopeButton : String = "All")
        {
            filteredLocations = locationList.filter
            {
                location in
                let scopeMatch = (scopeButton == "All" || location.name.lowercased().contains(scopeButton.lowercased()))
                if(searchController.searchBar.text != "")
                {
                    let searchTextMatch = location.name.lowercased().contains(searchText.lowercased())
                    
                    return scopeMatch && searchTextMatch
                }
                else
                {
                    return scopeMatch
                }
            }
            locationTableView.reloadData()
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
        
        print(restaurant)
        print(mealCode)
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
    
    func getMealsFixed(restaurant: String) -> [String: [[String: Any]]] {
        if !oneMealRestaurants.contains(restaurant) {
            return self.getMenu(restaurant: restaurant, mealCode: 0)
        }
        let session = URLSession.shared
        let url = URL(string: "https://netnutrition.cbord.com/nn-prod/duke/Unit/SelectUnitFromSideBar")!
        var url_request = URLRequest(url: url)
        url_request.httpMethod = "POST"
        url_request.httpBody = Data(String(format: "unitOid=%d", restaurantCodes[restaurant]!).utf8)
        
        let sem = DispatchSemaphore(value: 0)
        var key = ""
        var val = 0
        let task = session.dataTask(with: url_request, completionHandler: { data, response, error in
            if let data = data, let dataString = String(data: data, encoding: .utf8)?.decodingUnicodeCharacters {
                let dataStringSliced = String(dataString.prefix(dataString.indexOf(sub: "</section>")))
                var meals = [String: Int]()
                let range = NSRange(location: 0, length: dataStringSliced.count)
                let regex = try! NSRegularExpression(pattern: #"menuListSelectMenu\((\d+)\);\\">(.*?)<"#)
                let matches = regex.matches(
                    in: dataStringSliced,
                    options: [],
                    range: range
                )
                for match in matches {
                    for rangeIndex in 1..<match.numberOfRanges {
                        let matchRange = match.range(at: rangeIndex)
                        if let substringRange = Range(matchRange, in: dataStringSliced) {
                            let capture = String(dataStringSliced[substringRange])
                            if rangeIndex == 2 {
                                key = capture
                            } else {
                                val = Int(capture)!
                            }
                        }
                    }
                    meals[key] = val
                }
                sem.signal()
            }
        })
        task.resume()
        sem.wait()
        return self.getMenu(restaurant: restaurant, mealCode: val)
    }
    
    func getMealsDynamic(restaurant: String) -> [String: Int] {
        let session = URLSession.shared
        let url = URL(string: "https://netnutrition.cbord.com/nn-prod/duke/Unit/SelectUnitFromSideBar")!
        var url_request = URLRequest(url: url)
        url_request.httpMethod = "POST"
        url_request.httpBody = Data(String(format: "unitOid=%d", restaurantCodes[restaurant]!).utf8)
        
        let sem = DispatchSemaphore(value: 0)
        var key = ""
        var val = 0
        var meals = [String: Int]()
        let task = session.dataTask(with: url_request, completionHandler: { data, response, error in
            if let data = data, let dataString = String(data: data, encoding: .utf8)?.decodingUnicodeCharacters {
                let dataStringSliced = String(dataString.prefix(dataString.indexOf(sub: "</section>")))
                let range = NSRange(location: 0, length: dataStringSliced.count)
                let regex = try! NSRegularExpression(pattern: #"menuListSelectMenu\((\d+)\);\\">(.*?)<"#)
                let matches = regex.matches(
                    in: dataStringSliced,
                    options: [],
                    range: range
                )
                for match in matches {
                    for rangeIndex in 1..<match.numberOfRanges {
                        let matchRange = match.range(at: rangeIndex)
                        if let substringRange = Range(matchRange, in: dataStringSliced) {
                            let capture = String(dataStringSliced[substringRange])
                            if rangeIndex == 2 {
                                key = capture
                            } else {
                                val = Int(capture)!
                            }
                        }
                    }
                    meals[key] = val
                }
                sem.signal()
            }
        })
        task.resume()
        sem.wait()
        return meals
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
