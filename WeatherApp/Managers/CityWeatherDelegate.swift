//
//  CityWeatherDelegate.swift
//  WeatherApp
//
//  Created by Владимир Тимофеев on 15.03.2022.
//

import Foundation

protocol CityWeatherDelegate: AnyObject {
    func passFavourite(city: City, add: Bool)
}
