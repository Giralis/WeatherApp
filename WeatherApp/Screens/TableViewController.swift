//
//  ViewController.swift
//  WeatherApp
//
//  Created by Владимир Тимофеев on 09.03.2022.
//

import UIKit
import CoreLocation

class TableViewController: UITableViewController {

    var allCities = [City]()
    var favouriteCities = [City]()
    var cities = [[City]]()
    var filteredCities = [City]()
    
    var count = 0
    
    var currentLocation: [City]? {
        didSet {
            cities.insert(currentLocation!, at: 0)
            citiesTags.insert("Current location", at: 0)
            self.tableView.reloadData()
        }
    }
    
    var citiesTags = ["Favourite", "All"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        getLocation()
        getCities()
        filteredCities = allCities
        favouriteCities = UserDefaultsManager.shared.loadFavouriteCities() ?? [City]()
        cities = [favouriteCities, filteredCities]
    }
    
    //MARK: Get users current location and trigger didSet in currentLocation
    func getLocation() {
        LocationManager.shared.getUserLocation { [weak self] location in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if self.count == 0 {
                    self.count += 1
                    let coords = Coordinates(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                    let currentLocation = City(id: nil, name: "Current location", state: nil, country: nil, coord: coords)
                    self.currentLocation = [currentLocation]
                }
            }
        }
    }
    
    //MARK: Read list of cities from cityList.json
    func getCities() {
        if let citiesData = CityManager.shared.readFromFile() {
            allCities = citiesData
            tableView.reloadData()
        } else {
            print("Error while load cities from file")
        }
    }
    
    //MARK: Set navigation bar
    func setNavigationBar() {
        self.navigationItem.title = "WeatherApp"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return cities.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //if we don't have favourite cities and user disagrees to share location - we don't need title for header
        if section == 0 && cities.count == 1 {
            return nil
        } else if section == 1 && favouriteCities.isEmpty {
            return nil
        } else {
            return citiesTags[section]
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        let citySection = cities[indexPath.section]
        let city = citySection[indexPath.row]
        
        if #available(iOS 14.0, *) {
            var cellConfig = cell.defaultContentConfiguration()
            cellConfig.text = check(city: city)
            cell.contentConfiguration = cellConfig
        } else {
            cell.textLabel?.text = check(city: city)
        }
        
        return cell
    }
    
    //MARK: Check city for state and country to display in cell
    func check(city: City) -> String {
        if let country = city.country, country != "" {
            if let state = city.state, state != "" {
                return "\(city.name), \(state), \(country)"
            } else {
                return "\(city.name), \(country)"
            }
        } else {
            return "\(city.name)"
        }
    }
    
    //MARK: Comparison of coordinates to obtain data on the presence of the same city
    func compare(city: City) -> Bool {
        let lhsCoord = city.coord
        var result = false
        for rhs in favouriteCities {
            let rhsCoord = rhs.coord
            if lhsCoord.lat == rhsCoord.lat && lhsCoord.lon == rhsCoord.lon {
                result = true
            } else {
                continue
            }
        }
        return result
    }
    
    //MARK: Navigation preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail" {
            let detailVC = segue.destination as! DetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let section = cities[indexPath.section]
            detailVC.city = section[indexPath.row]
            detailVC.cityWeatherDelegate = self
            
            if compare(city: detailVC.city!) {
                detailVC.savedState = true
            } else {
                detailVC.savedState = false
            }
        }
    }
}

//MARK: - UISearchResultsUpdating need to update tableView with filtered array of cities
extension TableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            filteredCities = allCities
            return
        }
        
        filteredCities = searchText.isEmpty ? allCities : allCities.filter { $0.name.contains(searchText) }
        cities = searchText.isEmpty ? [currentLocation!, favouriteCities, filteredCities] : [filteredCities]
        tableView.reloadData()
    }
}

//MARK: - Delegate need to update array of favourite cities: delete or add new ones
extension TableViewController: CityWeatherDelegate {
    func passFavourite(city: City, add: Bool) {
        //if "save" button was activated and city won't be found in favouriteCities - append new city to favouriteCities
        if add && !compare(city: city) {
            favouriteCities.append(city)
            cities = [currentLocation!, favouriteCities, filteredCities]
        } else if !add && compare(city: city) {
            //if "save" button is not activated and we have city in favouriteCities - delete this city from favouriteCities and weather for this city
            if !favouriteCities.isEmpty {
                favouriteCities.remove(at: favouriteCities.firstIndex(where: { favCity in
                    let lhs = favCity.coord
                    let rhs = city.coord
                    if lhs.lon == rhs.lon && lhs.lat == rhs.lat {
                        return true
                    } else {
                        return false
                    }
                })!)
                UserDefaultsManager.shared.deleteWeather(for: city)
            }
            cities = [currentLocation!, favouriteCities, filteredCities]
        }
        tableView.reloadData()
        UserDefaultsManager.shared.save(favouriteCities: favouriteCities)
    }
}
