//
//  CurrencyVC.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-13.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit
import Charts


class CurrencyVC: UIViewController, AddNewCurrencyDelegate, IAxisValueFormatter {
  
  static let instance = CurrencyVC()
  
  //  MARK: Outlets
  @IBOutlet weak private var segmentedControlOutlet: UISegmentedControl!
  @IBOutlet weak private var doneBtnOutlet: UIButton!
  @IBOutlet weak private var baseVIew: UIView!
  @IBOutlet weak private var basePicker: UIPickerView!
  @IBOutlet weak private var blurView: UIVisualEffectView!
  @IBOutlet weak private var chartView: LineChartView!
  @IBOutlet weak private var currencyTableView: UITableView!
  @IBOutlet weak private var selectCurrencyView: UIView!
  @IBOutlet weak private var addNewCurrenncy: UIBarButtonItem!
  @IBOutlet weak private var baseLabel: UILabel!
  @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak private var baseAmountTextField: UITextField! {
    didSet {
      baseAmountTextField?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonBaseTextField)), onCancel: (target: self, action: #selector(cancelButtonBaseTextField)) )
    }
  }
  @IBOutlet weak private var baseFlag: UILabel!
  @IBOutlet weak private var baseAmountView: UIView!
  
  //  MARK: Variables
  private let defaults = UserDefaults()
  private let colors = Colors()
  private let fonts = Fonts()
  private var blurEffect: UIVisualEffect!
  private var countryArray = [Country]()
  private var numbers = [Double]()
  private var selectedCurrencyRow = Int()
  private var pickedRow = Int()
  private var selectedPickedProw = Int()
  private var startDate = String()
  private var endDate = String()
  private var units = [String]()
  
  private let currenciesFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ChosenCurrencies.plist")
  private let API_KEY = ""
  
  private var baseCurrencyArray = ["USD", "EUR", "BTC", "GBP", "AUD", "CAD", "JPY", "CHF", "CNY", "SEK", "NZD", "MXN", "SGD", "HKD", "NOK", "KRW", "TRY", "RUB", "INR","BRL","ZAR"]
  private var selectedToCompareCurrency = ""
  private var selectedBaseCurrency = "USD"
  private var pickedBaseCurrency = "USD"
  private var selectedSegment = 2
  private var last = "Week"
  private var amountToCompare = 1.0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    blurEffect = blurView.effect
    blurView.effect = nil
    blurView.isHidden = true
    
    basePicker.delegate = self
    basePicker.dataSource = self
    baseAmountTextField.delegate = self
    
    currencyTableView.tableFooterView = UIView()
    currencyTableView.dataSource = self
    currencyTableView.separatorColor = colors.lightGrey
    currencyTableView.isMultipleTouchEnabled = false
    currencyTableView.delegate = self
    currencyTableView.sectionHeaderHeight = 32
    
    segmentedControlOutlet.tintColor = colors.mainColor
    
    chartView.noDataText = ""
    chartView.noDataTextAlignment = .center
    chartView.noDataFont = fonts.noDataFont
    
    if selectedToCompareCurrency == "" {
      segmentedControlOutlet.isEnabled = false
      activityIndicator.stopAnimating()
    }
    
    definesPresentationContext = false
    
    loadUserCurrencies()
    loadDataFromUserDefaults()
    
  }
  
  //Get added currencies from AddCurrencyVC
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
  private func loadDataFromUserDefaults(){
    
    let dateFormatter = DateFormatter()
    let date = Date()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    self.navigationItem.leftBarButtonItem?.tintColor = colors.mainColor
    self.navigationItem.rightBarButtonItem?.tintColor = colors.mainColor
    
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
    if let savedAmountToCompare = defaults.string(forKey: "amountToCompare") {
      amountToCompare = Double(savedAmountToCompare)!
    }
    
    baseAmountTextField.text = "\(amountToCompare)"
    segmentedControlOutlet.selectedSegmentIndex = selectedSegment
    currencyTableView.selectRow(at: IndexPath.init(row: selectedCurrencyRow, section: 0), animated: false, scrollPosition: .none)
    
    if countryArray.count > 0 {
      getRatesForDataRange(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ooo) in
        self.updateChart()
      }
    }
    setBaseFlag()
    baseLabel.text = selectedBaseCurrency
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
  func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    if Int(value) < units.count {
      return units[Int(value)]
    } else {
      return "L"
    }
  }
  
  private func updateChart(){
    chartView.fitScreen()
    var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
    var filtredNumbers = [Double]()
    
    //Filter number of values
    switch selectedSegment {
    case 0:
      for (index, value) in numbers.enumerated() {
        if index % 29 == 0 {
          filtredNumbers.append(value)
          units = ["12m", "11m", "10m", "9m", "8m", "7m", "6m", "5m", "4m", "3m", "2m", "1m", "Now"]
        }
      }
      
    case 1:
      for (index, value) in numbers.enumerated() {
        if index % 3 == 0 {
          filtredNumbers.append(value)
          units = ["30d", "27d", "24d", "21d", "18d", "15d", "12d", "9d", "6d", "3d", "Now"]
        }
      }
      
    case 2:
      filtredNumbers = numbers
      units = ["7d", "6d", "5d", "4d", "3d", "2d", "1d", "Now"]
      
    default:
      break
    }
    
    //here is the for loop
    for i in 0..<filtredNumbers.count {
      let value = ChartDataEntry(x: Double(i), y: filtredNumbers[i].rounded(toPlaces: 3)) // here we set the X and Y status in a data chart entry
      lineChartEntry.append(value) // here we add it to the data set
    }
    
    let rateLine = LineChartDataSet(values: lineChartEntry, label: "\(selectedBaseCurrency)/\(selectedToCompareCurrency) Rates for Last \(last)") //Here we convert lineChartEntry to a LineChartDataSet
    
    let chartData = LineChartData(dataSet: rateLine)
    
    let marker = BalloonMarker(color: colors.lightGrey,
                               font: fonts.legendFont,
                               textColor: colors.black,
                               insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
    
    marker.chartView = chartView
    
    //Chart View
    chartView.marker = marker
    chartView.doubleTapToZoomEnabled = false
    chartView.scaleXEnabled = false
    chartView.scaleYEnabled = false
    chartView.highlightPerTapEnabled = true
    chartView.highlightPerDragEnabled = true
    
    //Rate Line
    rateLine.valueFormatter = DigitValueFormatter()
    rateLine.mode = .cubicBezier
    rateLine.cubicIntensity = 0.17
    rateLine.lineWidth = 1.5
    rateLine.circleHoleColor = UIColor.white
    rateLine.drawCircleHoleEnabled = true
    rateLine.drawCirclesEnabled = true
    rateLine.circleRadius = 3
    rateLine.circleHoleRadius = 2
    rateLine.circleColors = [colors.mainColor]
    rateLine.drawFilledEnabled = true
    rateLine.fillColor = colors.mainColor.withAlphaComponent(0.7)
    rateLine.drawValuesEnabled = false
    rateLine.valueFont = fonts.valueFont
    rateLine.valueTextColor = colors.greySubtitleColor
    rateLine.colors = [colors.mainColor] //Set Line Color
    
    //Legend
    chartView.legend.font = fonts.legendFont
    chartView.legend.textColor = colors.greySubtitleColor
    chartView.legend.form = .line
    chartView.legend.xOffset = 0
    chartView.minOffset = 15
    chartView.chartDescription?.text = ""
    
    //X Axis
    chartView.xAxis.labelFont = fonts.valueFont
    chartView.xAxis.labelTextColor = colors.greySubtitleColor
    chartView.xAxis.drawGridLinesEnabled = false
    chartView.xAxis.drawAxisLineEnabled = false
    chartView.xAxis.drawLabelsEnabled = true
    chartView.xAxis.labelPosition = .bottom
    chartView.xAxis.valueFormatter = self
    
    //Left Axis
    chartView.leftAxis.drawGridLinesEnabled = true
    chartView.leftAxis.gridLineWidth = 0.5
    chartView.leftAxis.gridColor = colors.lightGrey
    chartView.leftAxis.axisLineWidth = 0
    chartView.leftAxis.labelPosition = .insideChart
    chartView.leftAxis.drawLabelsEnabled = true
    chartView.leftAxis.labelFont = fonts.valueFont
    chartView.leftAxis.labelTextColor = colors.greySubtitleColor
    
    //Rigth Axis
    chartView.rightAxis.drawGridLinesEnabled = false
    chartView.rightAxis.axisLineWidth = 0
    chartView.rightAxis.drawLabelsEnabled = false
    
    if filtredNumbers.count > 0 {
      chartView.leftAxis.axisMaximum = (filtredNumbers.max()! * 1.02) //Max Range for Y
      chartView.leftAxis.axisMinimum = (filtredNumbers.min()! / 1.02) //Min Range for Y
    }
    
    let data = LineChartData() //This is the object that will be added to the chart
    
    data.addDataSet(rateLine) //Adds the line to the dataSet
    chartView.data = chartData //finally - it adds the chart data to the chart and causes an update
  }
  
  //  MARK: Actions
  
  @IBAction private func dismissBaseView(_ sender: Any) {
    animateOutBase()
  }
  
  @IBAction private func chooseBaseButton(_ sender: Any) {
    animateInBase()
  }
  
  private func setBaseFlag() {
    var flag = String()
    flag = Service.instance.flag(country: selectedBaseCurrency)
    
    if selectedBaseCurrency == "BTC" {
      baseFlag.text = "₿"
      baseFlag.font = UIFont.systemFont(ofSize: 30)
    } else {
      baseFlag.font = UIFont.systemFont(ofSize: 55)
      flag.removeLast()
      baseFlag.text = flag
    }
  }
  
  @IBAction private func baseDoneButton(_ sender: Any) {
    
    selectedBaseCurrency = pickedBaseCurrency
    
    setBaseFlag()
    
    baseLabel.text = "\(selectedBaseCurrency)"
    
    defaults.set(selectedBaseCurrency, forKey: "selectedBaseCurrency")
    getRatesForDataRange(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ppp) in
      self.updateChart()
    }
    selectedPickedProw = pickedRow
    defaults.set(selectedPickedProw, forKey: "selectedPickedProw")
    currencyTableView.reloadData()
    animateOutBase()
  }
  
  
  @IBAction private func segmentedControl(_ sender: Any) {
    
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
    print("YEAR \(startDate)")
      
    case 1: let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())
    last = "Month"
    selectedSegment = 1
    endDate = dateFormatter.string(from: date)
    startDate = dateFormatter.string(from: previousMonth!)
    getRatesForDataRange(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ooo) in
      self.updateChart()
    }
    saveData()
    print("MONTH \(startDate)")
      
    case 2: let previousWeek = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: Date())
    last = "Week"
    selectedSegment = 2
    endDate = dateFormatter.string(from: date)
    startDate = dateFormatter.string(from: previousWeek!)
    getRatesForDataRange(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (ooo) in
      self.updateChart()
    }
    saveData()
    print("WEEK \(startDate)")
      
    default:
      break
    }
  }
  
  @objc private func cancelButtonBaseTextField() {
    baseAmountTextField.text = "\(amountToCompare)"
    baseAmountTextField.resignFirstResponder()
  }
  
  @objc private func doneButtonBaseTextField() {
    var enteredAmount = baseAmountTextField.text
    
    if (enteredAmount?.count)! < 1 {
      enteredAmount = "\(0)"
      baseAmountTextField.text = "\(enteredAmount!)"
    }
    
    guard let amount = enteredAmount else { return }
    
    let dots = enteredAmount?.filter(){ $0 == "." }
    let count = dots?.count
    
    if count! > 1 || enteredAmount == "." {
      baseAmountTextField.text = "Wrong format..."
    } else {
      
      if (enteredAmount?.isAllowed)! {
        amountToCompare = Double(amount)!
        defaults.set(amountToCompare, forKey: "amountToCompare")
        currencyTableView.reloadData()
        baseAmountTextField.resignFirstResponder()
      } else {
        baseAmountTextField.text = "Wrong format..."
      }
    }
    
    print("AMOUNT TO COMPARE \(amountToCompare)")
  }
  
  //Save user data to userDefauts
  private func saveData(){
    defaults.set(startDate, forKey: "startDate")
    defaults.set(endDate, forKey: "endDate")
    defaults.set(selectedSegment, forKey: "selectedSegment")
    defaults.set(last, forKey: "last")
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
        
        getRatesForDataRange(from: selectedBaseCurrency, to: selectedToCompareCurrency, startDate: startDate, endDate: endDate) { (_) in
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
    view.backgroundColor = colors.lightGrey
    let label = UILabel(frame: CGRect(x: 8, y: 0, width: tableView.frame.size.width, height: 32))
    label.textAlignment = .left
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
    
    let cellSelection = UIView()
    cellSelection.backgroundColor = colors.lightGrey
    cell.selectedBackgroundView = cellSelection
    
    //Get rates for each currency in TableView
    getRates(from: selectedBaseCurrency, to: country.currencyId) { (returnedRate) in
      
      var symbol = String()
      var rate = Double()
      let name = country.currencyId
      let description = country.currencyName
      var getFlag = Service.instance.flag(country: country.id)
      
      if country.currencyName == "European euro" {
        getFlag = "🇪🇺"
      } else if country.currencyName == "United States dollar" {
        getFlag = "🇺🇸"
      } else if country.currencyName == "Bitcoin" {
        getFlag = "₿"
      }
      
      if country.currencySymbol != nil {
        symbol = country.currencySymbol!
      } else {
        symbol = ""
      }
      
      rate = (returnedRate * self.amountToCompare).rounded(toPlaces: 2)
      cell.configureCell(currencyName: name, currencyDescription: description, currencyRate: "\(rate)", flag: getFlag, symbol: symbol)
      
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
    pickedRow = row
    
  }
}

extension CurrencyVC: UITextFieldDelegate {
  
  //Animation for Select Base Currency View
  private func animateInBase()  {
    
    self.view.addSubview(baseVIew)
    baseVIew.center = self.view.center
    baseVIew.transform = CGAffineTransform.init(scaleX: 1.32, y: 1.32)
    baseVIew.alpha = 0
    baseVIew.layer.borderWidth = 1
    baseVIew.layer.borderColor = colors.lightGrey.cgColor
    blurView.isHidden = false
    baseAmountView.isHidden = true
    
    let selectRow = defaults.integer(forKey: "selectedPickedProw")
    basePicker.selectRow(selectRow, inComponent: 0, animated: false)
    
    UIView.animate(withDuration: 0.22) {
      self.blurView.effect = self.blurEffect
      self.baseVIew.alpha = 0.9
      self.doneBtnOutlet.isEnabled = false
      self.baseVIew.layer.cornerRadius = 20
      self.baseVIew.transform = CGAffineTransform.identity
    }
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  private func animateOutBase() {
    UIView.animate(withDuration: 0.22, animations: {
      self.baseVIew.transform = CGAffineTransform.init(scaleX: 1.32, y: 1.32)
      self.baseVIew.alpha = 0
      self.blurView.effect = nil
      self.blurView.isHidden = true
      self.baseAmountView.isHidden = false
    }) { (success: Bool) in
      self.baseVIew.removeFromSuperview()
    }
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  //Save User Currencies using PropertyListEncoder
  private func saveUserCurrencies() {
    
    let encoder = PropertyListEncoder()
    
    do {
      
      let data = try encoder.encode(countryArray)
      try data.write(to: currenciesFilePath!)
      
    } catch {
      print("error \(error)")
    }
    currencyTableView.reloadData()
  }
  
  private func loadUserCurrencies() {
    
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
  private func getRates(from: String, to: String, handler: @escaping (Double) -> Void) -> Void {
    
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
  private func getRatesForDataRange(from: String, to: String, startDate: String, endDate: String,  handler: @escaping ([Double]) -> Void) -> Void {
    
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
        self.chartView.highlightValue(nil, callDelegate: false)
      }
      }.resume()
  }
  
  //Limit number of characters in TextField
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let text = baseAmountTextField.text else { return true }
    let newLength = text.count + string.count - range.length
    return newLength <= 7
  }
}


















