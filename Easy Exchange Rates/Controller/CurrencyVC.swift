//
//  CurrencyVC.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-13.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit
import Charts
import SVProgressHUD

class CurrencyVC: UIViewController, AddNewCurrencyDelegate {
  
  static let instance = CurrencyVC()
  
  //  MARK: Outlets
  @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
  @IBOutlet weak var doneBtnOutlet: UIButton!
  @IBOutlet weak var baseVIew: UIView!
  @IBOutlet weak var basePicker: UIPickerView!
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var chartView: LineChartView!
  @IBOutlet weak var currencyTableView: UITableView!
  @IBOutlet var selectCurrencyView: UIView!
  
  //  MARK: Variables
  var blurEffect: UIVisualEffect!
  
  var countryArray = [Country]()
  let defaults = UserDefaults()
  var numbers = [Double]()
  var selectedCurrencyRow = Int()
  var selectedPickerRow = Int()
  var startDate = String()
  var endDate = String()
  
  let API_KEY = "8ad20f84-95b2-495f-95e4-1c7bb1f46b11"
  var baseCurrencyArray = ["USD", "EUR", "BTC", "GBP", "AUD", "CAD", "JPY", "CHF", "CNY", "SEK", "NZD", "MXN", "SGD", "HKD", "NOK", "KRW", "TRY", "RUB", "INR","BRL","ZAR"]
  var pickedBaseCurrency = "USD"
  var selectedBaseCurrency = "USD"
  var selectedToCompareCurrency = "CAD"
  let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ChosenCurrencies.plist")
  var selectedSegment = 2
  var last = "Week"
  
  
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    blurEffect = blurView.effect
    blurView.effect = nil
    blurView.isHidden = true
    basePicker.dataSource = self
    basePicker.delegate = self
    currencyTableView.delegate = self
    currencyTableView.dataSource = self
    definesPresentationContext = false
    segmentedControlOutlet.tintColor = UIColor(rgb: 0x1B9AAA)
    currencyTableView.separatorColor = UIColor(rgb: 0x1B9AAA)
    
    loadUserCurrencies()
    loadDataFromUserDefaults()
  }
  
  //Get added currencies
  func userAddNewCurrency(currency: Country) {
    countryArray.append(currency)
    saveUserCurrencies()
  }
  
  // Load saved data
  func loadDataFromUserDefaults(){
    
    let dateFormatter = DateFormatter()
    let date = Date()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    if countryArray.count == 0 {
      countryArray.append(Country.init(currencyId: "CAD", currencyName: "Canadian dollar", currencySymbol: "$", id: "CA", name: "Canada"))
      saveUserCurrencies()
    }
    self.navigationItem.leftBarButtonItem?.title = selectedBaseCurrency
    
    let previousWeek = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: Date())
    endDate = dateFormatter.string(from: date)
    startDate = dateFormatter.string(from: previousWeek!)
    
    if let savedBaseCurrency = defaults.string(forKey: "selectedBaseCurrency") {
      selectedBaseCurrency = savedBaseCurrency
    }
    if let savedToCompareCurrency = defaults.string(forKey: "selectedToCompareCurrency") {
      selectedToCompareCurrency = savedToCompareCurrency
    }
    if let savedStartDate = defaults.string(forKey: "startDate") {
      startDate = savedStartDate
    }
    if let savedEndDate = defaults.string(forKey: "endDate") {
      endDate = savedEndDate
    }
    if let savedSegment = defaults.string(forKey: "selectedSegment") {
      selectedSegment = Int(savedSegment)!
    }
    if let savedLast = defaults.string(forKey: "last") {
      last = savedLast
    }
    if let savedSelectedCurrency = defaults.string(forKey: "selectedCurrencyRow") {
      selectedCurrencyRow = Int(savedSelectedCurrency)!
    }
    segmentedControlOutlet.selectedSegmentIndex = selectedSegment
    
    currencyTableView.selectRow(at: IndexPath.init(row: selectedCurrencyRow, section: 0), animated: false, scrollPosition: .none)
    
    getRatesForMonth(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ooo) in
      self.updateGraph()
    }
    self.navigationItem.leftBarButtonItem?.title = selectedBaseCurrency
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.popToRootViewController(animated: true)
  }
  
  
  //MARK: Charts
  func updateGraph(){
    
    var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
    var filtredNumbers = [Double]()
    
    switch selectedSegment {
    case 0:
      for (index, value) in numbers.enumerated() {
        if index % 30 == 0 {
          filtredNumbers.append(value)
        }
      }
      
    case 1:
      for (index, value) in numbers.enumerated() {
        if index % 3 == 0 {
          filtredNumbers.append(value)
        }
      }
      
    case 2:
      filtredNumbers = numbers
      
    default:
      break
    }
    
    //here is the for loop
    for i in 0..<filtredNumbers.count {
      
      let value = ChartDataEntry(x: Double(i), y: filtredNumbers[i]) // here we set the X and Y status in a data chart entry
      lineChartEntry.append(value) // here we add it to the data set
    }
    
    let rateLine = LineChartDataSet(values: lineChartEntry, label: "Exchange Rate \(selectedBaseCurrency)/\(selectedToCompareCurrency) for Last \(last)") //Here we convert lineChartEntry to a LineChartDataSet
    
    rateLine.valueFormatter = DigitValueFormatter()
    rateLine.mode = .cubicBezier
    rateLine.cubicIntensity = 0.2
    rateLine.lineWidth = 2
    rateLine.circleHoleColor = UIColor.white
    rateLine.drawCircleHoleEnabled = true
    rateLine.drawCirclesEnabled = true
    rateLine.circleRadius = 3
    rateLine.circleHoleRadius = 2
    rateLine.circleColors = [UIColor(rgb: 0x1B9AAA)]
    rateLine.drawFilledEnabled = true
    rateLine.fillColor = UIColor(rgb: 0x1BEDD7)
    rateLine.drawValuesEnabled = true
    rateLine.valueFont = UIFont(name: "HelveticaNeue-Light", size: 11)!
    rateLine.valueTextColor = UIColor(rgb: 0x929292)
    rateLine.colors = [UIColor(rgb: 0x1B9AAA)] //Set Line Color
    
    chartView.legend.font = UIFont(name: "HelveticaNeue-Light", size: 16)!
    chartView.legend.textColor = UIColor(rgb: 0x929292)
    chartView.legend.form = .circle
    chartView.minOffset = 15
    chartView.chartDescription?.text = ""
    chartView.xAxis.drawGridLinesEnabled = false
    chartView.xAxis.drawAxisLineEnabled = false
    chartView.xAxis.drawLabelsEnabled = false
    chartView.leftAxis.drawGridLinesEnabled = true
    chartView.rightAxis.drawGridLinesEnabled = false
    chartView.leftAxis.gridColor = UIColor(rgb: 0xEBEBEB)
    chartView.leftAxis.axisLineWidth = 0
    chartView.rightAxis.axisLineWidth = 0
    chartView.leftAxis.gridLineWidth = 0.5
    chartView.leftAxis.axisMaximum = (filtredNumbers.max()! * 1.05)//Max Range for Y
    chartView.leftAxis.axisMinimum = (filtredNumbers.min()! / 1.05)//Min Range for Y
    
    let data = LineChartData() //This is the object that will be added to the chart
    data.addDataSet(rateLine) //Adds the line to the dataSet
    
    chartView.data = data //finally - it adds the chart data to the chart and causes an update
    chartView.doubleTapToZoomEnabled = false
    chartView.isUserInteractionEnabled = true
    chartView.rightAxis.drawLabelsEnabled = false
    chartView.leftAxis.drawLabelsEnabled = false
    chartView.leftAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 16)!
    chartView.leftAxis.labelTextColor = UIColor(rgb: 0x929292)
    chartView.zoomOut()
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
    defaults.set(selectedBaseCurrency, forKey: "selectedBaseCurrency")
    getRatesForMonth(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ppp) in
      self.updateGraph()
    }
    currencyTableView.reloadData()
    animateOutBase()
  }
  
  func saveData(){
    defaults.set(startDate, forKey: "startDate")
    defaults.set(endDate, forKey: "endDate")
    defaults.set(selectedSegment, forKey: "selectedSegment")
    defaults.set(last, forKey: "last")
  }
  
  @IBAction func segmentedControl(_ sender: Any) {
    
    let dateFormatter = DateFormatter()
    let date = Date()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    switch segmentedControlOutlet.selectedSegmentIndex {
      
    case 0: let previousYear = Calendar.current.date(byAdding: .year, value: -1, to: Date())
    last = "Year"
    selectedSegment = 0
    endDate = dateFormatter.string(from: date)
    startDate = dateFormatter.string(from: previousYear!)
    getRatesForMonth(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ooo) in
      self.updateGraph()
    }
    saveData()
    print("YEAR \(endDate)")
      
    case 1: let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
    last = "Month"
    selectedSegment = 1
    endDate = dateFormatter.string(from: date)
    startDate = dateFormatter.string(from: previousMonth!)
    getRatesForMonth(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ooo) in
      self.updateGraph()
    }
    saveData()
    print("MONTH \(endDate)")
      
    case 2: let previousWeek = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: Date())
    last = "Week"
    selectedSegment = 2
    endDate = dateFormatter.string(from: date)
    startDate = dateFormatter.string(from: previousWeek!)
    getRatesForMonth(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ooo) in
      self.updateGraph()
    }
    saveData()
    print("WEEK \(endDate)")
      
    default:
      break
    }
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
    
    selectedToCompareCurrency = countryArray[indexPath.row].currencyId
    defaults.set(selectedToCompareCurrency, forKey: "selectedToCompareCurrency")
    selectedCurrencyRow = indexPath.row
    defaults.set(selectedCurrencyRow, forKey: "selectedCurrencyRow")
    
    getRatesForMonth(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ppp) in
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
    selectedPickerRow = row
    defaults.set(selectedPickerRow, forKey: "selectedPickerRow")
  }
}


extension CurrencyVC {
  
  func animateInBase()  {
    self.view.addSubview(baseVIew)
    baseVIew.center = self.view.center
    baseVIew.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
    baseVIew.alpha = 0
    blurView.isHidden = false
    
    let selectRow = defaults.integer(forKey: "selectedPickerRow")
    basePicker.selectRow(selectRow, inComponent: 0, animated: false)
    
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
      self.blurView.isHidden = true
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
  
  // Get rates for pair of currencies
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
  
  // Get range of rates for date range
  func getRatesForMonth(from: String, to: String, startDate: String, endDate: String,  handler: @escaping ([Double]) -> Void) -> Void {
    SVProgressHUD.show(withStatus: "Loading Chart Data")
    
    let dateRangeRates = URL(string: "https://currencyconverterapi.com/api/v5/convert?q=\(from)_\(to)&compact=ultra&date=\(startDate)&endDate=\(endDate)&apiKey=\(API_KEY)")
    
    print("RANGE URL \(dateRangeRates!)")
    URLSession.shared.dataTask(with: dateRangeRates!) { (data, urlResponse, error) in
      
      DispatchQueue.main.async {
        
        guard let dataToDecode = data, error == nil, urlResponse != nil else {return}
        
        let results = try? JSONSerialization.jsonObject(with: dataToDecode, options: []) as! [String : [String:Double]]
        
        var res = [String:Double]()
        
        for i in (results?.values)! {
          res = i
        }
        self.numbers = Array(res.values)
        handler(self.numbers)
        SVProgressHUD.dismiss()
      }
      }.resume()
  }
}


















