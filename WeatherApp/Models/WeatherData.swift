//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Владимир Тимофеев on 10.03.2022.
//

import Foundation

struct APIResponse: Codable {
    let current: CurrentWeatherData
    let daily: [DailyWeatherData]
}

struct CurrentWeatherData: Codable {
    let temp: Double
    let pressure: Double
    let humidity: Double
    let windSpeed: Double
    let windDeg: Int
    let weather: [Weather]
    
    enum CodingKeys: String, CodingKey {
        case temp
        case pressure
        case humidity
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case weather
    }
}

struct Weather: Codable {
    let main: String
    let description: String
}

struct DailyWeatherData: Codable {
    let pop: Double
}
