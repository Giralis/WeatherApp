//
//  DetailViewController.swift
//  WeatherApp
//
//  Created by Владимир Тимофеев on 11.03.2022.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempButton: UIButton!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDegLabel: UILabel!
    @IBOutlet weak var popLabel: UILabel!
    @IBOutlet weak var favouriteCity: UIBarButtonItem!
    
    @IBAction func favouriteCityTapped(_ sender: UIBarButtonItem) {
        savedState.toggle()
        if savedState {
            favouriteCity.title = "Delete"
        } else {
            favouriteCity.title = "Save"
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        buttonState.toggle()
        changeButtonState(buttonState)
    }
    
    var weather: APIResponse? {
        didSet {
            setParameters()
        }
    }
    
    var city: City?
    var buttonState = true
    var savedState: Bool!
    
    weak var cityWeatherDelegate: CityWeatherDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCityLabel()
        if savedState {
            favouriteCity.title = "Delete"
        } else {
            favouriteCity.title = "Save"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getWeather()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //save city and weather if need to
        cityWeatherDelegate?.passFavourite(city: city!, add: savedState)
        if savedState {
            UserDefaultsManager.shared.save(weather: weather!, for: city!)
        }
    }
    
    //MARK: Properly set label for city
    func setCityLabel() {
        guard let city = city else { return }
        if let country = city.country, country != "" {
            if let state = city.state, state != "" {
                cityLabel.text = "\(city.name), \(state), \(country)"
            } else {
                cityLabel.text = "\(city.name), \(country)"
            }
        } else {
            cityLabel.text = city.name
        }
    }
    
    //MARK: Triggered by didSet in weather when we got the weather data
    func setParameters() {
        guard let weather = weather else { return }
        DispatchQueue.main.async {
            self.changeButtonState(self.buttonState)
            self.pressureLabel.text = "Давление: \(String(weather.current.pressure)) мм рт ст"
            self.humidityLabel.text = "Влажность: \(String(weather.current.humidity))%"
            self.windSpeedLabel.text = "Скорость ветра: \(String(weather.current.windSpeed)) м/с"
            self.windDegLabel.text = "Направление ветра: \(String(weather.current.windDeg))°"
            self.popLabel.text = "Вероятность выпадения осадков сегодня: \(String(weather.daily[0].pop * 100))%"
        }
    }
    
    //MARK: Temperature button changes title when tapped
    func changeButtonState(_ condition: Bool) {
        guard let weather = weather else { return }
        if condition {
            tempButton.setTitle("\(String(weather.current.temp))°C", for: .normal)
        } else {
            let fahrenheit = (weather.current.temp * 9)/5 + 32
            tempButton.setTitle("\(String(fahrenheit))°F", for: .normal)
        }
    }

    //MARK: Getting weather data and trigger the didSet in weather
    func getWeather() {
        NetworkManager.shared.getWeather(coordinates: city!.coord) { result in
            switch result {
            case .success(let response):
                self.weather = response
            case .failure(let error):
                self.weather = UserDefaultsManager.shared.loadWeather(for: self.city!)
                print(error)
            }
        }
    }
}
