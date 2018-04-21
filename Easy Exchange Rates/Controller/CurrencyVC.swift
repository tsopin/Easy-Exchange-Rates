//
//  CurrencyVC.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-13.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit

class CurrencyVC: UIViewController, AddNewCurrencyDelegate {
  
  func userAddNewCurrency(currency: [Country]) {
    for i in currency {
      countryArray.append(i)
      compareToCurrency.append(i.currencyId)
    }
    currencyTableView.reloadData()
  }
  
  
  //  MARK: Variables
  let API_KEY = "8ad20f84-95b2-495f-95e4-1c7bb1f46b11"
  var blurEffect: UIVisualEffect!
  var baseCurrencyArray = ["USD", "CAD", "RUB", "EUR", "GBP"]
  var countryArray = [Country]()
  var rateArray = [Double]()
  var exchangeRate = String()
  var pickedBaseCurrency = String()
  var selectedBaseCurrency = "USD"
  var compareToCurrency = [String]()
  var numbers = [Double]()
  
  //  MARK: Outlets
  @IBOutlet weak var doneBtnOutlet: UIButton!
  @IBOutlet weak var baseVIew: UIView!
  @IBOutlet weak var basePicker: UIPickerView!
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var chartView: UIView!
  @IBOutlet weak var currencyTableView: UITableView!
  @IBOutlet var selectCurrencyView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    blurEffect = blurView.effect
    blurView.effect = nil
    basePicker.dataSource = self
    basePicker.delegate = self
    currencyTableView.delegate = self
    currencyTableView.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
  }
  
  
  func getRatesClosure(from: String, to: String, handler: @escaping (Double) -> Void) -> Void {
    
    var rate = Double()
    
    print("WE COMPARE \(from) to \(to)")
    
    let rateUrl = URL(string: "https://currencyconverterapi.com/api/v5/convert?q=\(from)_\(to)&compact=ultra&apiKey=\(API_KEY)")
    
    URLSession.shared.dataTask(with: rateUrl!) { (data, urlResponse, error) in
      
      DispatchQueue.main.async {
        
        guard let dataToDecode = data, error == nil, urlResponse != nil else {return}
        
        do {
          
          let results = try? JSONSerialization.jsonObject(with: dataToDecode, options: []) as! [String:Double]
          
          print("WE'VE GOT RESPONSE \(results!)")
          
          for i in results! {
            rate = i.value
          }
          
          handler(rate)
          
          print("WE'VE GOT VALUE \(rate)")
          
        } catch {
          
          print("eerrro")
        }
      }
      }.resume()
    
  }
  
  
  
  
  
  @IBAction func refreshRates(_ sender: Any) {
    
    currencyTableView.reloadData()
    
  }
  
  
  
  
  
  
  
  
  
  
  //  MARK: Actions
  @IBAction func dismissBaseView(_ sender: Any) {
    animateOutBase()
  }
  
  @IBAction func chooseBaseButton(_ sender: Any) {
    animateInBase()
  }
  
  
  @IBAction func baseDoneButton(_ sender: Any) {
    
    selectedBaseCurrency = pickedBaseCurrency
    self.navigationItem.leftBarButtonItem?.title = selectedBaseCurrency
    currencyTableView.reloadData()
    animateOutBase()
  }
  
  @IBOutlet weak var selectDoneButton: UIButton!
  
  
  
  @IBAction func addCurrencyButton(_ sender: Any) {
    //    animateInList()
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "addCurency" {
      
      let destinationVC = segue.destination as! AddCurrencyVC
      
      destinationVC.delegate = self 
      
    }
  }
  
}


//MARK: Extension TableView
extension CurrencyVC: UITableViewDelegate, UITableViewDataSource {
  
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    compareToCurrency.remove(at: indexPath.row)
    countryArray.remove(at: indexPath.row)
    currencyTableView.deleteRows(at: [indexPath], with: .automatic)
  }
  
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
    
    let country = countryArray[indexPath.row]
    let cell = currencyTableView.dequeueReusableCell(withIdentifier: "currencyCell") as! CurrencyCell
    
    getRatesClosure(from: selectedBaseCurrency, to: country.currencyId) { (returnedRate) in
      
      var symbol = String()
      var rate = Double()
      let name = country.currencyId
      let description = country.currencyName
      let getFlag = Service.instance.flag(country: country.id)
      
      if country.currencySymbol != nil {
        symbol = country.currencySymbol!
      } else {
        symbol = ""
      }
      
      rate = returnedRate.rounded(toPlaces: 2)
      
      cell.configeureCell(currencyName: name, currencyDescription: description, currencyRate: "\(rate)", flag: getFlag, symbol: symbol)
      
    }
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


// Animate Base Currency View
extension CurrencyVC {
  
  
  func animateInBase()  {
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
  
  func animateOutBase() {
    UIView.animate(withDuration: 0.2, animations: {
      self.baseVIew.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
      self.baseVIew.alpha = 0
      self.blurView.effect = nil
    }) { (success: Bool) in
      self.baseVIew.removeFromSuperview()
      
    }
  }
}


















