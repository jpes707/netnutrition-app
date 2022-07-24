//
//  WebViewController.swift
//  NetNutritionApp
//
//  Created by Johnny Pesavento on 3/22/22.
//

import UIKit

class WebViewController: UIViewController, URLSessionDelegate {
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    func getItemNutrition(itemId: Int) {
        let session = URLSession.shared
        let url = URL(string: "https://netnutrition.cbord.com/nn-prod/duke/NutritionDetail/ShowItemNutritionLabel")!
        var url_request = URLRequest(url: url)
        url_request.httpMethod = "POST"
        let s = String(format: "detailOid=%d", itemId).utf8
        url_request.httpBody = Data(s)
        
        let task = session.dataTask(with: url_request, completionHandler: { data, response, error in
            if let data = data, let dataString = String(data: data, encoding: .utf8)?.decodingUnicodeCharacters {
                let range = NSRange(location: 0, length: dataString.count)
                var nutrition = [String: Double]()
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
                    print("ALERT")
                    print(itemId)
                }
                
                
                
                
                
                
                
                
                
                
                // MODIFY THIS LINE TO ADD TO VIEWCONTROLLER LATER ON
                print(nutrition)
                
                
                
                
                
                
                
                
                
                
            }
        })
        task.resume()
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
                
                
                
                
                
                
                
                
                
                
                // MODIFY THIS LINE TO ADD TO VIEWCONTROLLER LATER ON
                print(restaurantDict)
                
                
                
                
                
                
                
                
                
                sem.signal()
            }
            // print(response)
            // print(error)
        })
        task.resume()
        sem.wait()
        return restaurantDict
    }
    
    func getMeals(restaurant: String) {
        if !varietyRestaurants.contains(restaurant) {
            self.getMenu(restaurant: restaurant, mealCode: 0)
            return
        }
        let session = URLSession.shared
        let url = URL(string: "https://netnutrition.cbord.com/nn-prod/duke/Unit/SelectUnitFromSideBar")!
        var url_request = URLRequest(url: url)
        url_request.httpMethod = "POST"
        url_request.httpBody = Data(String(format: "unitOid=%d", restaurantCodes[restaurant]!).utf8)
        
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
                var key = ""
                var val = 0
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
                if meals.count == 1 {
                    self.getMenu(restaurant: restaurant, mealCode: val)
                } else {
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    // MODIFY THIS LINE TO ADD TO VIEWCONTROLLER LATER ON
                    print(meals)
                    //self.getMenu(restaurant: restaurant, mealCode: meals["Dinner"]!)
                    
                    
                    
                    
                    
                    
                    
                    
                    
                }
            }
        })
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let r = Redirect()
        r.makeRequest()
        
        delayWithSeconds(2) {
            self.getMeals(restaurant: "Gyotaku")
            self.getMeals(restaurant: "Marketplace")
        }
    }
}
