//
//  CurrencyVC.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-13.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CurrencyVC: UIViewController {
  
  //  MARK: Variables
  var blurEffect: UIVisualEffect!
  var baseCurrencyArray = ["USD", "CAD", "RUB", "EUR", "GBP"]
  var countryArray = [Country]()
  var rateArray = [Double]()
  
  
  var exchangeRate = String()
  var pickedBaseCurrency = String()
  var selectedBaseCurrency = String()
  var compareToCurrency = [String]()
  
  var numbers = [Double]()
  
  //  MARK: Outlets
  @IBOutlet weak var doneBtnOutlet: UIButton!
  @IBOutlet weak var baseVIew: UIView!
  @IBOutlet weak var basePicker: UIPickerView!
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var chartView: UIView!
  @IBOutlet weak var currencyTableView: UITableView!
  
  let jsonUrl = URL(string: "https://currencyconverterapi.com/api/v5/countries?apiKey=8ad20f84-95b2-495f-95e4-1c7bb1f46b11")
  let currencyUrl = URL(string: "https://currencyconverterapi.com/api/v5/convert?q=USD_AFN,USD_AUD,USD_BDT,USD_BRL,USD_KHR&compact=ultra&apiKey=8ad20f84-95b2-495f-95e4-1c7bb1f46b11")
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
  }
  
  func getRates() {
    guard let downloadUrl = currencyUrl else {return}
    
    URLSession.shared.dataTask(with: downloadUrl) { (data, urlResponse, error) in
      
      guard let dataToDecode = data, error == nil, urlResponse != nil else {
        return
      }
      
      let decoder = JSONDecoder()
      
      do {

        let results = try decoder.decode(CurrencyRate.self, from: dataToDecode)
        
        
        
        self.rateArray = [results.USD_AFN, results.USD_AUD, results.USD_BDT, results.USD_BRL, results.USD_KHR]
        print("DATA \(self.rateArray)")
        DispatchQueue.main.async {
          self.currencyTableView.reloadData()
        }
        
//        for (_, value) in results {
//
//          self.rateArray.append(value)
////          print("DATA \(self.rateArray)")
//        }
//        DispatchQueue.main.async {
//          self.currencyTableView.reloadData()
//        }
//        print("ARRAY \(self.rateArray)")
      } catch {
        print("eerrro")
      }
      }.resume()
    
  }
  
  
  func getCurrencyList(){
    guard let downloadUrl = jsonUrl else {return}
    URLSession.shared.dataTask(with: downloadUrl) { (data, urlResponse, error) in
      guard let data = data, error == nil, urlResponse != nil else {
        return
      }
      let decoder = JSONDecoder()
      let file = Bundle.main.url(forResource: "currencyList", withExtension: "json")
      do {
        let ooo = try Data(contentsOf: file!)
        let results = try decoder.decode(Results.self, from: ooo)
        for (_, value) in results.results {
          self.countryArray.append(value)
        }
        DispatchQueue.main.async {
          self.currencyTableView.reloadData()
        }
//        print("ARRAY \(self.countryArray)")
      } catch {
//        print("eerrro")
      }
      }.resume()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    blurEffect = blurView.effect
    blurView.effect = nil
    basePicker.dataSource = self
    basePicker.delegate = self
    
    currencyTableView.delegate = self
    currencyTableView.dataSource = self
    getCurrencyList()
    getRates()
  }
  
  
  
  
  func animateIn()  {
    self.view.addSubview(baseVIew)
    baseVIew.center = self.view.center
    baseVIew.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
    baseVIew.alpha = 0
    
    UIView.animate(withDuration: 0.2) {
      self.blurView.effect = self.blurEffect
      self.baseVIew.alpha = 0.8
      self.doneBtnOutlet.isEnabled = false
      self.baseVIew.layer.cornerRadius = 20
      
      self.baseVIew.transform = CGAffineTransform.identity
    }
    
  }
  
  func animateOut() {
    UIView.animate(withDuration: 0.2, animations: {
      self.baseVIew.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
      self.baseVIew.alpha = 0
      self.blurView.effect = nil
    }) { (success: Bool) in
      self.baseVIew.removeFromSuperview()
      
    }
    
  }
  
  let API_KEY = "8ad20f84-95b2-495f-95e4-1c7bb1f46b11"
  
  
  
  
  
  
  //  MARK: Actions
  @IBAction func dismissBaseView(_ sender: Any) {
    animateOut()
  }
  
  @IBAction func chooseBaseButton(_ sender: Any) {
    animateIn()
  }
  
  @IBAction func addNewCurrencyToListButton(_ sender: Any) {
    getCurrencyList()
    
  }
  
  @IBAction func baseDoneButton(_ sender: Any) {
    
    selectedBaseCurrency = pickedBaseCurrency
    self.navigationItem.leftBarButtonItem?.title = selectedBaseCurrency
    
    animateOut()
  }
  func changetitle() {
    let item = self.navigationItem.leftBarButtonItem!
    let button = item.customView as! UIButton
    button.setTitle("Change", for: .normal)
  }
  
  
}
//MARK: Extension TableView
extension CurrencyVC: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Compare to"
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
    
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return countryArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = currencyTableView.dequeueReusableCell(withIdentifier: "currencyCell") as! CurrencyCell
    let country = countryArray[indexPath.row]
    let rate = rateArray[indexPath.row]
    
    let name = country.name
    let description = country.currencyName
    
    
    
    cell.configeureCell(currencyName: name, currencyDescription: description, currencyRate: "\(rate.rounded(toPlaces: 3))", currencySymbol: "$")
    
    return cell
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    //    compareToCurrency = [currencyArray[indexPath.row].code]
    
  }
  
}





//MARK: PickerView
extension CurrencyVC: UIPickerViewDelegate, UIPickerViewDataSource  {
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return baseCurrencyArray.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return baseCurrencyArray[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.doneBtnOutlet.isEnabled = true
    pickedBaseCurrency = baseCurrencyArray[row]
    
  }
  
}




















