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
        cityLabel.text = city?.name
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
        cityWeatherDelegate?.passFavourite(city: city!, add: savedState)
        if savedState {
            UserDefaultsManager.shared.save(weather: weather!, for: city!)
        }
    }
    
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
    
    func changeButtonState(_ condition: Bool) {
        guard let weather = weather else { return }
        if condition {
            tempButton.setTitle("\(String(weather.current.temp))°C", for: .normal)
        } else {
            let fahrenheit = (weather.current.temp * 9)/5 + 32
            tempButton.setTitle("\(String(fahrenheit))°F", for: .normal)
        }
    }

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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
