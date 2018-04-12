//
//  CurrencyVC.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-12.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit
import Charts



class CurrencyVC: UIViewController {
  
  
  
  @IBOutlet weak var picker: UIPickerView!
  @IBOutlet weak var pickerviewVIEW: UIView!
  @IBOutlet weak var oneUnitLabel: UILabel!
  @IBOutlet weak var currentRateLabel: UILabel!
  @IBOutlet weak var compareToLabel: UILabel!

  @IBOutlet weak var chartView: LineChartView!
  @IBOutlet weak var currencyTableView: UITableView!
  
  var toCompare = ["USD", "CAD", "RUR", "EUR", "GBP"]
  var currencyArray: [Currencies] = []
  
 var numbers = [Double]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    pickerviewVIEW.isHidden = true
    picker.dataSource = self
    picker.delegate = self
    
    currencyTableView.delegate = self
    currencyTableView.dataSource = self
    
    numbers = [12.2, 56.14, 454.1]
    updateGraph()
    for item in CurrencyData.currencyItems() {
      currencyArray.append(contentsOf: item.item)
    }
    
  }
  @IBAction func compareToButton(_ sender: Any) {
    pickerviewVIEW.isHidden = false
  }
  

  func updateGraph(){
    var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
    
    
    
    //here is the for loop
    for i in 0..<numbers.count {
      
      let value = ChartDataEntry(x: Double(i), y: numbers[i]) // here we set the X and Y status in a data chart entry
      
      lineChartEntry.append(value) // here we add it to the data set
    }
    
    let line1 = LineChartDataSet(values: lineChartEntry, label: "Number") //Here we convert lineChartEntry to a LineChartDataSet
    
    line1.colors = [NSUIColor.blue] //Sets the colour to blue
    
    
    let data = LineChartData() //This is the object that will be added to the chart
    
    data.addDataSet(line1) //Adds the line to the dataSet
    
    
    chartView.data = data //finally - it adds the chart data to the chart and causes an update
    
    chartView.chartDescription?.text = "My awesome chart" // Here we set the description for the grap
    
  }

  

}
//MARK: TableView
extension CurrencyVC: UITableViewDelegate, UITableViewDataSource {
  
  
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currencyArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = currencyTableView.dequeueReusableCell(withIdentifier: "currencyCell") as! CurrencyCell
    
    cell.configeureCell(currencyName: currencyArray[indexPath.row].code, currencyDescription: currencyArray[indexPath.row].description, currencyImage: currencyArray[indexPath.row].image)
    return cell
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    oneUnitLabel.text = "1 \(currencyArray[indexPath.row].code) ="
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
    compareToLabel.text = toCompare[row]
    pickerviewVIEW.isHidden = true
  }
  
}

