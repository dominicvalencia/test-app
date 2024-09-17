//
//  Car.swift
//  TestApp
//
//  Created by Dominic Valencia on 9/17/24.
//

import Foundation
import RealmSwift

class Car: Object, Identifiable {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var make: String = ""
    @Persisted var model: String = ""
    @Persisted var customerPrice: Double = 0.0
    @Persisted var marketPrice: Double = 0.0
    @Persisted var rating: Int = 0
    @Persisted var prosList: RealmSwift.List<String> = RealmSwift.List<String>()
    @Persisted var consList: RealmSwift.List<String> = RealmSwift.List<String>()
}


struct DecodedCar: Codable {
    let make: String
    let model: String
    let customerPrice: Double
    let marketPrice: Double
    let rating: Int
    let prosList: [String]
    let consList: [String]
}
