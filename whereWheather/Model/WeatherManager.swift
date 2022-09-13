//
//  WeatherManager.swift
//  whereWheather
//
//  Created by 쭌이 on 2022/09/13.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager,
                          weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL =  "https://api.openweathermap.org/data/2.5/weather?appid=218202b0a2de9ffbe377c4d689343c19&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeahter(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
 
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {       //URl 만들기
            let session = URLSession(configuration: .default)   //URL Session 만들기
            
            //Give URlSession a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume() //task start
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? { //JSONDecoder로 각자의 형식에 맞춰 모델로 변환
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let name = decodeData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
                                       
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}
