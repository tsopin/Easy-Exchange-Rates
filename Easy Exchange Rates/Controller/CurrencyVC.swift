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
  
  static let instance = CurrencyVC()
  
  //  MARK: Outlets
  @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
  @IBOutlet weak var doneBtnOutlet: UIButton!
  @IBOutlet weak var baseVIew: UIView!
  @IBOutlet weak var basePicker: UIPickerView!
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var chartView: LineChartView!
  @IBOutlet weak var currencyTableView: UITableView!
  @IBOutlet weak var selectCurrencyView: UIView!
  @IBOutlet weak var addNewCurrenncy: UIBarButtonItem!
  @IBOutlet weak var baseButtonOutlet: UIBarButtonItem!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  //  MARK: Variables
  let defaults = UserDefaults()
  var blurEffect: UIVisualEffect!
  var countryArray = [Country]()
  var numbers = [Double]()
  var selectedCurrencyRow = Int()
  var selectedPickerRow = Int()
  var startDate = String()
  var endDate = String()
  
  let currenciesFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ChosenCurrencies.plist")
  let API_KEY = ""
  let greySubtitleColor = UIColor(rgb: 0x929292)
  let mainColor = UIColor(rgb: 0x1f61ff)
  var baseCurrencyArray = ["USD", "EUR", "BTC", "GBP", "AUD", "CAD", "JPY", "CHF", "CNY", "SEK", "NZD", "MXN", "SGD", "HKD", "NOK", "KRW", "TRY", "RUB", "INR","BRL","ZAR"]
  var selectedToCompareCurrency = ""
  var selectedBaseCurrency = "USD"
  var pickedBaseCurrency = "USD"
  var selectedSegment = 2
  var last = "Week"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    blurEffect = blurView.effect
    blurView.effect = nil
    blurView.isHidden = true
    basePicker.delegate = self
    basePicker.dataSource = self
    
    currencyTableView.delegate = self
    definesPresentationContext = false
    currencyTableView.dataSource = self
    chartView.noDataTextAlignment = .center
    currencyTableView.sectionHeaderHeight = 32
    chartView.noDataText = "No Data to Display"
    segmentedControlOutlet.tintColor = mainColor
    currencyTableView.separatorColor = mainColor
    currencyTableView.isMultipleTouchEnabled = false
    chartView.noDataFont = UIFont(name: "HelveticaNeue-Light", size: 20)!
    
    if selectedToCompareCurrency == "" {
      segmentedControlOutlet.isEnabled = false
      activityIndicator.stopAnimating()
    }
    
    loadUserCurrencies()
    loadDataFromUserDefaults()
  }
  
  //Get added currencies
  func userAddNewCurrency(currency: Country) {
    
    countryArray.append(currency)
    let lastCountry = countryArray.count - 1
    selectedToCompareCurrency = countryArray[lastCountry].currencyId
    defaults.set(selectedToCompareCurrency, forKey: "selectedToCompareCurrency")
    selectedCurrencyRow = lastCountry
    currencyTableView.selectRow(at: IndexPath.init(row: countryArray.count, section: 0), animated: false, scrollPosition: .none)
    getRatesForDataRange(from: selectedBaseCurrency, to: countryArray[lastCountry].currencyId, startDate: startDate, endDate: endDate) { (ooo) in
      self.updateChart()
    }
    saveUserCurrencies()
  }
  
  // Load saved data
  func loadDataFromUserDefaults(){
    
    let dateFormatter = DateFormatter()
    let date = Date()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    //        if countryArray.count == 0 {
    //          countryArray.append(Country.init(currencyId: "CAD", currencyName: "Canadian dollar", currencySymbol: "$", id: "CA", name: "Canada"))
    //          saveUserCurrencies()
    //        }
    
    self.navigationItem.leftBarButtonItem?.title = selectedBaseCurrency
    self.navigationItem.leftBarButtonItem?.tintColor = mainColor
    self.navigationItem.rightBarButtonItem?.tintColor = mainColor
    
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
    
    if countryArray.count > 0 {
      getRatesForDataRange(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ooo) in
        self.updateChart()
      }
    }
    self.navigationItem.leftBarButtonItem?.title = selectedBaseCurrency
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if countryArray.count > 0 {
      
      segmentedControlOutlet.isEnabled = true
      
    } else if countryArray.count == 1 {
      
      selectedToCompareCurrency = countryArray[0].currencyId
      
    }
    self.navigationController?.popToRootViewController(animated: true)
  }
  
  
  //MARK: Charts
  func updateChart(){
    chartView.fitScreen()
    
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
    rateLine.lineWidth = 2.5
    rateLine.circleHoleColor = UIColor.white
    rateLine.drawCircleHoleEnabled = true
    rateLine.drawCirclesEnabled = true
    rateLine.circleRadius = 3
    rateLine.circleHoleRadius = 2
    rateLine.circleColors = [mainColor]
    rateLine.drawFilledEnabled = true
    rateLine.fillColor = mainColor.withAlphaComponent(0.7)
    rateLine.drawValuesEnabled = true
    rateLine.valueFont = UIFont(name: "HelveticaNeue-Light", size: 11)!
    rateLine.valueTextColor = greySubtitleColor
    rateLine.colors = [mainColor] //Set Line Color
    
    chartView.legend.font = UIFont(name: "HelveticaNeue-Light", size: 16)!
    chartView.legend.textColor = greySubtitleColor
    chartView.legend.form = .line
    chartView.legend.xOffset = 0
    chartView.minOffset = 18
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
    
    if filtredNumbers.count > 0 {
      chartView.leftAxis.axisMaximum = (filtredNumbers.max()! * 1.05) //Max Range for Y
      chartView.leftAxis.axisMinimum = (filtredNumbers.min()! / 1.05) //Min Range for Y
    }
    
    let data = LineChartData() //This is the object that will be added to the chart
    data.addDataSet(rateLine) //Adds the line to the dataSet
    
    chartView.data = data //finally - it adds the chart data to the chart and causes an update
    chartView.doubleTapToZoomEnabled = false
    chartView.isUserInteractionEnabled = true
    chartView.rightAxis.drawLabelsEnabled = false
    chartView.leftAxis.drawLabelsEnabled = false
    chartView.leftAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 16)!
    chartView.leftAxis.labelTextColor = greySubtitleColor
    chartView.highlightPerTapEnabled = false
    chartView.highlightPerDragEnabled = false
    
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
    getRatesForDataRange(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ppp) in
      self.updateChart()
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
    getRatesForDataRange(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ooo) in
      self.updateChart()
    }
    saveData()
    print("YEAR \(endDate)")
      
    case 1: let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
    last = "Month"
    selectedSegment = 1
    endDate = dateFormatter.string(from: date)
    startDate = dateFormatter.string(from: previousMonth!)
    getRatesForDataRange(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ooo) in
      self.updateChart()
    }
    saveData()
    print("MONTH \(endDate)")
      
    case 2: let previousWeek = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: Date())
    last = "Week"
    selectedSegment = 2
    endDate = dateFormatter.string(from: date)
    startDate = dateFormatter.string(from: previousWeek!)
    getRatesForDataRange(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ooo) in
      self.updateChart()
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
    
    if countryArray.count >= 1  {
      
      if indexPath.row == selectedCurrencyRow {
        selectedToCompareCurrency = countryArray[0].currencyId
        defaults.set(selectedToCompareCurrency, forKey: "selectedToCompareCurrency")
        selectedCurrencyRow = 0
        
        
        getRatesForDataRange(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ppp) in
          self.updateChart()
        }
        updateChart()
      }
    }
    
    if countryArray.count < 1{
      selectedToCompareCurrency = ""
      defaults.set(selectedToCompareCurrency, forKey: "selectedToCompareCurrency")
      segmentedControlOutlet.isEnabled = false
      numbers.removeAll()
      //      baseButtonOutlet.isEnabled = false
      updateChart()
    }
    saveUserCurrencies()
    saveData()
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    currencyTableView.sectionHeaderHeight = 32
    
    var separatorText = String()
    
    if countryArray.count == 0 {
      separatorText = "Add Currencies to Compare"
    } else {
      separatorText = "Compare to "
    }
    
    let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 32))
    view.backgroundColor = UIColor(rgb: 0xEBEBEB)
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 32))
    label.textAlignment = .center
    label.font = UIFont(name: "HelveticaNeue-Light", size: 18)!
    view.addSubview(label)
    label.text = separatorText
    label.textColor = UIColor.black
    return view
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
    
    //    if countryArray.count >= indexPath.row && indexPath.row > selectedCurrencyRow  {
    //      self.currencyTableView.selectRow(at: IndexPath.init(row: selectedCurrencyRow, section: 0), animated: true, scrollPosition: .none)
    //    }
    
    getRates(from: selectedBaseCurrency, to: country.currencyId) { (returnedRate) in
      
      var symbol = String()
      var rate = Double()
      let name = country.currencyId
      let description = country.currencyName
      let  getFlag = Service.instance.flag(country: country.id)
      
      //      if country.currencyName == "European euro" {
      //        getFlag = "🇪🇺"
      //      }
      
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
    
    getRatesForDataRange(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ppp) in
      self.updateChart()
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
    baseVIew.layer.borderWidth = 1
    baseVIew.layer.borderColor = UIColor(rgb: 0xD6D6D6).cgColor
    blurView.isHidden = false
    addNewCurrenncy.isEnabled = false
    baseButtonOutlet.isEnabled = false
    
    let selectRow = defaults.integer(forKey: "selectedPickerRow")
    basePicker.selectRow(selectRow, inComponent: 0, animated: false)
    
    UIView.animate(withDuration: 0.2) {
      self.blurView.effect = self.blurEffect
      self.baseVIew.alpha = 1
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
      self.addNewCurrenncy.isEnabled = true
      self.baseButtonOutlet.isEnabled = true
    }) { (success: Bool) in
      self.baseVIew.removeFromSuperview()
    }
  }
  
  func saveUserCurrencies() {
    
    let encoder = PropertyListEncoder()
    
    do {
      let data = try encoder.encode(countryArray)
      try data.write(to: currenciesFilePath!)
      
    } catch {
      print("error \(error)")
    }
    currencyTableView.reloadData()
  }
  
  func loadUserCurrencies() {
    
    if let data = try? Data(contentsOf: currenciesFilePath!) {
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
  func getRatesForDataRange(from: String, to: String, startDate: String, endDate: String,  handler: @escaping ([Double]) -> Void) -> Void {
    
    activityIndicator.startAnimating()
    
    let dateRangeRates = URL(string: "https://currencyconverterapi.com/api/v5/convert?q=\(from)_\(to)&compact=ultra&date=\(startDate)&endDate=\(endDate)&apiKey=\(API_KEY)")
    
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
        self.activityIndicator.stopAnimating()
      }
      }.resume()
  }
}


















