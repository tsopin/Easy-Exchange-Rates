//
//  CurrencyVC.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-13.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit
import Charts

class CurrencyVC: UIViewController, AddNewCurrencyDelegate {
  
 
  
  func userAddNewCurrency(currency: Country) {
    
    countryArray.append(currency)
//    compareToCurrency.append(currency.currencyId)
    print("GOT \(countryArray) OBJECTS")
    saveUserCurrencies()
    
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
  let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ChosenCurrencies.plist")
  var numbers = [Double]()

  
  //  MARK: Outlets
  @IBOutlet weak var doneBtnOutlet: UIButton!
  @IBOutlet weak var baseVIew: UIView!
  @IBOutlet weak var basePicker: UIPickerView!
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var chartView: LineChartView!
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
    definesPresentationContext = false
    
    loadUserCurrencies()

    getRatesForMonth(from: "USD", to: "CAD") { (ooo) in
      self.updateGraph()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
  }

  @IBAction func refreshRates(_ sender: Any) {
    
    currencyTableView.reloadData()
    
  }
  
  func updateGraph(){
    var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
    
    //here is the for loop
    for i in 0..<numbers.count {
      
      let value = ChartDataEntry(x: Double(i), y: numbers[i]) // here we set the X and Y status in a data chart entry
      
      lineChartEntry.append(value) // here we add it to the data set
    }
    
    let line1 = LineChartDataSet(values: lineChartEntry, label: "Rate") //Here we convert lineChartEntry to a LineChartDataSet
    line1.mode = .cubicBezier
    line1.cubicIntensity = 0.2
    line1.lineWidth = 2.0
    
    line1.colors = [NSUIColor.blue] //Sets the colour to blue
    chartView.animate(xAxisDuration: 1.0 , yAxisDuration: 1.0, easingOption: .easeInBounce)
    chartView.xAxis.drawGridLinesEnabled = false
    chartView.xAxis.drawAxisLineEnabled = false
    let data = LineChartData() //This is the object that will be added to the chart
    
    data.addDataSet(line1) //Adds the line to the dataSet
    
    
    chartView.data = data //finally - it adds the chart data to the chart and causes an update
    chartView.backgroundColor = UIColor.white
    chartView.doubleTapToZoomEnabled = false
    //    chartView.isUserInteractionEnabled = false
    chartView.resetZoom()
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
//    compareToCurrency.remove(at: indexPath.row)
    countryArray.remove(at: indexPath.row)
    currencyTableView.deleteRows(at: [indexPath], with: .automatic)
    saveUserCurrencies()
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
    
    getRates(from: selectedBaseCurrency, to: country.currencyId) { (returnedRate) in
      
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
    
    getRatesForMonth(from: selectedBaseCurrency, to: countryArray[indexPath.row].currencyId) { (ppp) in
      self.updateGraph()
    }
    
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


extension CurrencyVC {
  
  
  func animateInBase()  {
    self.view.addSubview(baseVIew)
    baseVIew.center = self.view.center
    baseVIew.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
    baseVIew.alpha = 0
    basePicker.selectRow(2, inComponent: 0, animated: false)
    
    
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
  
  func saveUserCurrencies() {
    
    let encoder = PropertyListEncoder()
    do {
      let data = try encoder.encode(countryArray)
      try data.write(to: dataFilePath!)
      
    } catch {
      print("error \(error)")
    }
    currencyTableView.reloadData()
  }
  
  func loadUserCurrencies() {
    
    if let data = try? Data(contentsOf: dataFilePath!) {
      let decoder = PropertyListDecoder()
      do {
        countryArray = try decoder.decode([Country].self, from: data)
      } catch {
        print("Error \(error)")
      }
    }
  }
  
  
  func getRates(from: String, to: String, handler: @escaping (Double) -> Void) -> Void {
    
    var rate = Double()

    let rateUrl = URL(string: "https://currencyconverterapi.com/api/v5/convert?q=\(from)_\(to)&compact=ultra&apiKey=\(API_KEY)")

    URLSession.shared.dataTask(with: rateUrl!) { (data, urlResponse, error) in

      DispatchQueue.main.async {

        guard let dataToDecode = data, error == nil, urlResponse != nil else {return}

        let results = try? JSONSerialization.jsonObject(with: dataToDecode, options: []) as! [String:Double]

        for i in results! {
          rate = i.value
        }

        handler(rate)
      }
      }.resume()
  }
  
  func getRatesForMonth(from: String, to: String, handler: @escaping ([Double]) -> Void) -> Void {
    
    var rate = Double()
    let dateRangeRates = URL(string: "https://currencyconverterapi.com/api/v5/convert?q=\(from)_\(to)&compact=ultra&date=2018-04-01&endDate=2018-04-08&apiKey=\(API_KEY)")
//    let rateUrl = URL(string: "https://currencyconverterapi.com/api/v5/convert?q=\(from)_\(to)&compact=ultra&apiKey=\(API_KEY)")
    
    URLSession.shared.dataTask(with: dateRangeRates!) { (data, urlResponse, error) in
      
      DispatchQueue.main.async {
        
        guard let dataToDecode = data, error == nil, urlResponse != nil else {return}
        
        let results = try? JSONSerialization.jsonObject(with: dataToDecode, options: []) as! [String : [String:Double]]
        
        var res = [String:Double]()
        
        for i in (results?.values)! {
          res = i
        }
        
        self.numbers = Array(res.values)
        
        
        print("RANGE \(res)")
       
//        for i in results! {
//          rate = i.value
//        }
        
        handler(self.numbers)
      }
      }.resume()
  }
  
  
  
}


















