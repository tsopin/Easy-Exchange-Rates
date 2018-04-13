//
//  CryptoVC.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-12.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON



class CryptoVC: UIViewController {
  
  
  
  @IBOutlet weak var picker: UIPickerView!
  @IBOutlet weak var pickerviewVIEW: UIView!
  @IBOutlet weak var oneUnitLabel: UILabel!
  @IBOutlet weak var currentRateLabel: UILabel!
  @IBOutlet weak var compareToLabel: UILabel!
  
  @IBOutlet weak var chartView: LineChartView!
  @IBOutlet weak var currencyTableView: UITableView!
  
  var toCompare = ["USD", "CAD", "RUR", "EUR", "GBP"]
  var currencyArray: [Currencies] = []
  var exchangeRate = String()
  
  
  
  let API_KEY = "ZVN9XKF9SYW4N1FB"
  var firstCode = String()
  var secondCode = String()
  
  var numbers = [Double]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    pickerviewVIEW.isHidden = true
    picker.dataSource = self
    picker.delegate = self
    oneUnitLabel.pushTransition(0.2)
    
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
    pickerviewVIEW.isHidden = false
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
    currentRateLabel.text = "\(exchangeRate.rounded(toPlaces: 3))"
    
    
  }
  
  
  
  
  func updateGraph(){
    var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
    
    //here is the for loop
    for i in 0..<numbers.count {
      
      let value = ChartDataEntry(x: Double(i), y: numbers[i]) // here we set the X and Y status in a data chart entry
      
      lineChartEntry.append(value) // here we add it to the data set
    }
    
    let line1 = LineChartDataSet(values: lineChartEntry, label: "Number") //Here we convert lineChartEntry to a LineChartDataSet
    line1.mode = .cubicBezier
    line1.cubicIntensity = 0.2
    line1.lineWidth = 5.0
    
    line1.colors = [NSUIColor.blue] //Sets the colour to blue
    chartView.animate(xAxisDuration: 1.0 , yAxisDuration: 1.0, easingOption: .easeInBounce)
    chartView.xAxis.drawGridLinesEnabled = false
    chartView.xAxis.drawAxisLineEnabled = false
    let data = LineChartData() //This is the object that will be added to the chart
    
    data.addDataSet(line1) //Adds the line to the dataSet
    
    
    chartView.data = data //finally - it adds the chart data to the chart and causes an update
    chartView.backgroundColor = UIColor.gray
    chartView.doubleTapToZoomEnabled = false
    //    chartView.isUserInteractionEnabled = false
    chartView.resetZoom()
  }
  
  
  
}
//MARK: TableView
extension CryptoVC: UITableViewDelegate, UITableViewDataSource {
  
  
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currencyArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = currencyTableView.dequeueReusableCell(withIdentifier: "currencyCell") as! CurrencyCell
    
    cell.configeureCell(currencyName: currencyArray[indexPath.row].code, currencyDescription: currencyArray[indexPath.row].description, currencyImage: currencyArray[indexPath.row].image)
    return cell
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    oneUnitLabel.pushTransition(0.2)
    oneUnitLabel.text = "1 \(currencyArray[indexPath.row].code) ="
    numbers = currencyArray[indexPath.row].rate
    firstCode = currencyArray[indexPath.row].code
    
    getCurrencyData(cryptoCode: firstCode, marketCode: secondCode)
    currentRateLabel.text = exchangeRate
    
    updateGraph()
  }
  
}









//MARK: PickerView
extension CryptoVC: UIPickerViewDelegate, UIPickerViewDataSource  {
  
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
    compareToLabel.text = toCompare[row]
    secondCode = toCompare[row]
    getCurrencyData(cryptoCode: firstCode, marketCode: secondCode)
    
    pickerviewVIEW.isHidden = true
  }
  
}

