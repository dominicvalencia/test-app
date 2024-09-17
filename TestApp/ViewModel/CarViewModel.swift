//
//  CarViewModel.swift
//  TestApp
//
//  Created by Dominic Valencia on 9/17/24.
//

import Foundation
import RealmSwift

class CarViewModel: ObservableObject {
    private var realm: Realm
    
    init() {
        self.realm = try! Realm()
    }
    
    func loadInitialDataIfNeeded(completion: @escaping ((Bool) -> Void)) {
        if realm.objects(Car.self).isEmpty {
            loadJSONToRealm(completion: completion)
        } else {
            completion(true)
        }
    }
    
    func loadJSONToRealm(completion: @escaping ((Bool) -> Void)) {
        guard let fileURL = Bundle.main.url(forResource: "car_list", withExtension: "json") else {
            print("Error: car_list file not found.")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            
            let decodedCars = try decoder.decode([DecodedCar].self, from: data)
            let realm = try Realm()
            
            try realm.write {
                for decodedCar in decodedCars {
                    let car = Car()
                    car.id = UUID() 
                    car.make = decodedCar.make
                    car.model = decodedCar.model
                    car.customerPrice = decodedCar.customerPrice
                    car.marketPrice = decodedCar.marketPrice
                    car.rating = decodedCar.rating
                    car.prosList.append(objectsIn: decodedCar.prosList)
                    car.consList.append(objectsIn: decodedCar.consList)
                    realm.add(car, update: .all)
                }
            }
            completion(true)
        } catch {
            print("Error loading JSON to Realm: \(error)")
            completion(false)
        }
    }
    
    func filteredCars(filterMake: String, filterModel: String) -> [Car] {
        let cars = realm.objects(Car.self)
        
        let filteredCars = cars.filter { car in
            (filterMake.isEmpty || filterMake == "Any Make" || car.make.localizedCaseInsensitiveContains(filterMake)) &&
            (filterModel.isEmpty || filterModel == "Any Model" || car.model.localizedCaseInsensitiveContains(filterModel))
        }
        
        return Array(filteredCars)
    }
}
