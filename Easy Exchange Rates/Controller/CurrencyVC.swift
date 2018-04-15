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
  var currencyArray = [Currencies]()
  

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
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let jsonUrl = "https://currencyconverterapi.com/api/v5/convert?q=USD_USD,USD_CAD,USD_RUB,USD_EUR,USD_GBP&compact=ultra&apiKey=8ad20f84-95b2-495f-95e4-1c7bb1f46b11"
    let urrl = URL(string: jsonUrl)
    
    URLSession.shared.dataTask(with: urrl!){(data, response, error) in
      
      
      do {
        self.currencyArray = try JSONDecoder().decode([Currencies].self, from: data!)
        for eachCurrency in self.currencyArray {
          print(eachCurrency.code)
          
        }
      }
      catch {
        print("error")
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
    return CurrencyData.instance.getCurrencies().count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = currencyTableView.dequeueReusableCell(withIdentifier: "currencyCell") as! CurrencyCell
    return cell
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    compareToCurrency = [currencyArray[indexPath.row].code]
    
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




















