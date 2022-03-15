//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Владимир Тимофеев on 10.03.2022.
//

import Foundation

class NetworkManager {
    private init() {}
    
    static let shared = NetworkManager()
    private let apiKey = "7c02abfda3f30a3f7340141314fe6fd2"
    
    //MARK: Create url and get the data from api
    func getWeather(coordinates: Coordinates, completion: @escaping ((Result<APIResponse, Error>) -> Void)) {
        let urlComponents = setURLComponents(with: coordinates)
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        
        let task = URLSession(configuration: .default)
        
        task.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let jsonDecoder = JSONDecoder()
                    let result = try jsonDecoder.decode(APIResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    //MARK: Set url
    private func setURLComponents(with coordinates: Coordinates) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.openweathermap.org"
        urlComponents.path = "/data/2.5/onecall"
        urlComponents.queryItems = [URLQueryItem(name: "lat", value: String(coordinates.lat)),
                                    URLQueryItem(name: "lon", value: String(coordinates.lon)),
                                    URLQueryItem(name: "exclude", value: "minutely,hourly"),
                                    URLQueryItem(name: "appid", value: apiKey),
                                    URLQueryItem(name: "units", value: "metric")]
        return urlComponents
    }
}
