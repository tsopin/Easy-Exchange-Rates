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

  
  @IBOutlet weak var chooseView: UIView!
  @IBOutlet weak var pickerView: UIPickerView!
  @IBOutlet weak var currencyTableView: UITableView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var codeLabel: UILabel!
  @IBAction func getRatesButton(_ sender: Any) {
    
  }
  
  @IBAction func chooseBaseButton(_ sender: Any) {
    chooseView.isHidden = false
  }
  var toCompare = ["USD", "CAD", "RUR", "EUR", "GBP"]
  var currencyArray: [Currencies] = []
  var exchangeRate = String()
  
  
  
  
  let API_KEY = "ZVN9XKF9SYW4N1FB"
  var firstCode = String()
  var secondCode = String()
  
  var numbers = [Double]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    chooseView.isHidden = true
    pickerView.dataSource = self
    pickerView.delegate = self
    codeLabel.pushTransition(0.2)
    
    firstCode = "USD"
    firstCode = "USD"
    currencyTableView.delegate = self
    currencyTableView.dataSource = self
    
    numbers = [12.2, 56.14, 454.1, 212.34, 100.1]
    //    updateGraph()
    for item in CurrencyData.currencyItems() {
      currencyArray.append(contentsOf: item.item)
    }
    
  }
  @IBAction func compareToButton(_ sender: Any) {
    chooseView.isHidden = false
  }
  
  func getCurrencyData(cryptoCode: String, marketCode: String) {
    
    let url = "https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=\(cryptoCode)&to_currency=\(marketCode)&apikey=\(API_KEY)"
    Alamofire.request(url, method: .get).responseJSON { (response) in
      if response.result.isSuccess {
        print("SUCCESS")
        let currencyData : JSON = JSON(response.result.value!)
        print(" DATA \(url)")
        self.updateCurrencyData(json: currencyData)
        
        
      } else {
        //        print("ERROR \(response.result.error)")
      }
    }
    
  }
  
  func updateCurrencyData(json: JSON) {
    
    var exchangeRate = json["Realtime Currency Exchange Rate"]["5. Exchange Rate"].doubleValue
    let toRur = json["Realtime Currency Exchange Rate"]["3. To_Currency Code"].stringValue
    let fromRur = json["Realtime Currency Exchange Rate"]["1. From_Currency Code"].stringValue
    
    print("FROM \(fromRur) TO \(toRur)")
    
    if fromRur != "RUR" && toRur == "RUR"  {
      exchangeRate = (exchangeRate)/1000
    } else if fromRur == "RUR" && toRur != "RUR" {
      exchangeRate = (exchangeRate)*1000
    }
    
    print(" EXCHANGE \(exchangeRate)")
    
    
  }

  
}
//MARK: TableView
extension CurrencyVC: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Compare to"
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
    
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currencyArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = currencyTableView.dequeueReusableCell(withIdentifier: "currencyCell") as! CurrencyCell
    
    cell.configeureCell(currencyName: currencyArray[indexPath.row].code, currencyDescription: currencyArray[indexPath.row].description, currencyImage: currencyArray[indexPath.row].image)
    return cell
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    codeLabel.pushTransition(0.2)
    codeLabel.text = "\(currencyArray[indexPath.row].code)"
    numbers = currencyArray[indexPath.row].rate
    firstCode = currencyArray[indexPath.row].code
    
    getCurrencyData(cryptoCode: firstCode, marketCode: secondCode)
    
   
  }
  
}









//MARK: PickerView
extension CurrencyVC: UIPickerViewDelegate, UIPickerViewDataSource  {
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return toCompare.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return toCompare[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    codeLabel.text = toCompare[row]
    secondCode = toCompare[row]
    getCurrencyData(cryptoCode: firstCode, marketCode: secondCode)
    
    chooseView.isHidden = true
  }
  
}
