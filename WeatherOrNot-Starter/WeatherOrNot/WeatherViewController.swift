/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import PromiseKit
import CoreLocation

private let errorColor = UIColor(red: 0.96, green: 0.667, blue: 0.690, alpha: 1)
private let oneHour: TimeInterval = 3600 // Seconds per hour
private let randomCities = [("Tokyo", "JP", 35.683333, 139.683333),
                            ("Jakarta", "ID", -6.2, 106.816667),
                            ("Delhi", "IN", 28.61, 77.23),
                            ("Manila", "PH", 14.58, 121),
                            ("São Paulo", "BR", -23.55, -46.633333)]

class WeatherViewController: UIViewController {
  @IBOutlet private var placeLabel: UILabel!
  @IBOutlet private var tempLabel: UILabel!
  @IBOutlet private var iconImageView: UIImageView!
  @IBOutlet private var conditionLabel: UILabel!
  @IBOutlet private var randomWeatherButton: UIButton!
  
  let weatherAPI = WeatherHelper()
  let locationHelper = LocationHelper()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateWithCurrentLocation()
  }
  
  private func updateWithCurrentLocation() {
    handleMockLocation()
  }
  
  private func handleMockLocation() {
    let coordinate = CLLocationCoordinate2DMake(37.966667, 23.716667)
    handleLocation(city: "Athens", state: "Greece", coordinate: coordinate)
  }
  
  private func handleLocation(placemark: CLPlacemark) {
    handleLocation(city: placemark.locality,
                   state: placemark.administrativeArea,
                   coordinate: placemark.location!.coordinate)
  }
  
  private func handleLocation(
    city: String?,
    state: String?,
    coordinate: CLLocationCoordinate2D
    ) {
    if let city = city,
      let state = state {
      self.placeLabel.text = "\(city), \(state)"
    }
    

    weatherAPI.getWeather(atLatitude: coordinate.latitude, longitude: coordinate.longitude)
      .done { [weak self] weatherInfo in
        
        self?.updateUI(with: weatherInfo)
      }
      .catch { [weak self] error in
        guard let self = self else { return }
        
        self.tempLabel.text = "--"
        self.conditionLabel.text = error.localizedDescription
        self.conditionLabel.textColor = errorColor
    }
  }

  
  private func updateUI(with weatherInfo: WeatherHelper.WeatherInfo) {
    
    let tempMeasurement = Measurement(value: weatherInfo.main.temp, unit: UnitTemperature.kelvin)
    let formatter = MeasurementFormatter()
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .none
    formatter.numberFormatter = numberFormatter
    let tempStr = formatter.string(from: tempMeasurement)
    
    DispatchQueue.main.async { [weak self] in
      
      guard let self = self else { return }
      
      self.tempLabel.text = tempStr
      self.placeLabel.text = weatherInfo.name
      self.conditionLabel.text = weatherInfo.weather.first?.description ?? "empty"
      self.conditionLabel.textColor = UIColor.white
    }
  }
  
  @IBAction func showRandomWeather(_ sender: AnyObject) {

  }
}

// MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    guard let _ = textField.text else { return false }

    handleMockLocation()

    return true
  }
}
