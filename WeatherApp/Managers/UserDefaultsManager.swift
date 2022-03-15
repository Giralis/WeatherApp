//
//  UserDefaultsManager.swift
//  WeatherApp
//
//  Created by Владимир Тимофеев on 11.03.2022.
//

import Foundation

class UserDefaultsManager {
    private init() {}
    
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    
    func save(weather: APIResponse, for city: City) {
        let jsonEncoder = JSONEncoder()
        let coord = city.coord
        do {
            let data = try jsonEncoder.encode(weather)
            defaults.set(data, forKey: "\(coord.lat),\(coord.lon)")
        } catch {
            print("Error occurred while saving the weather")
        }
    }
    
    func save(favouriteCities: [City]) {
        let jsonEncoder = JSONEncoder()
        do {
            let data = try jsonEncoder.encode(favouriteCities)
            defaults.set(data, forKey: "favouriteCities")
        } catch {
            print("Error occurred while saving the cities")
        }
    }
    
    func loadWeather(for city: City) -> APIResponse? {
        let jsonDecoder = JSONDecoder()
        let coord = city.coord
        do {
            guard let data = defaults.data(forKey: "\(coord.lat),\(coord.lon)") else {
                print("Error occurred while loading the weather")
                return nil
            }
            
            let result = try jsonDecoder.decode(APIResponse.self, from: data)
            return result
        } catch {
            print("Error occurred while loading the weather")
            return nil
        }
    }
    
    func loadFavouriteCities() -> [City]? {
        let jsonDecoder = JSONDecoder()
        do {
            guard let data = defaults.data(forKey: "favouriteCities") else {
                print("Error occurred while loading the cities")
                return nil
            }
            let result = try jsonDecoder.decode([City].self, from: data)
            return result
        } catch {
            print("Error occurred while loading the cities")
            return nil
        }
    }
    
    func deleteWeather(for city: City) {
        let coord = city.coord
        defaults.removeObject(forKey: "\(coord.lat),\(coord.lon)")
    }
}
