//
//  FileManager.swift
//  WeatherApp
//
//  Created by Владимир Тимофеев on 11.03.2022.
//

import Foundation

final class CityManager {
    private init() {}
    static let shared = CityManager()
    
    func readFromFile() -> [City]? {
        guard let path = Bundle.main.path(forResource: "cityList", ofType: "json") else { return nil }
        let url = URL(fileURLWithPath: path)
        
        do {
            let jsonDecoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            let result = try jsonDecoder.decode([City].self, from: data)
            return result
        } catch {
            print(error)
            return nil
        }
    }
}
