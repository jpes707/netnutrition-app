//
//  FoodInfo.swift
//  NetNutritionApp
//
//  Created by Henry Huynh on 4/16/22.
//

import Foundation
import RealmSwift

class FoodInfo: Object {
    @Persisted var name: String?
    @Persisted var id: String?
    @Persisted var location: String?
    @Persisted var day: String?
    @Persisted var time: String?
    @Persisted var date = Date()
    @Persisted var nutrition : Map<String, Double>

}
