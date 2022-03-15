//
//  City.swift
//  WeatherApp
//
//  Created by Владимир Тимофеев on 09.03.2022.
//

import Foundation

struct City: Codable {
    var id: Int?
    var name: String
    var state: String?
    var country: String?
    var coord: Coordinates
}
