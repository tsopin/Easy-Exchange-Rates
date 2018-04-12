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
  

  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    pickerviewVIEW.isHidden = true
    picker.dataSource = self
    picker.delegate = self
    
    currencyTableView.delegate = self
    currencyTableView.dataSource = self
    setChartValues()
    
    for item in CurrencyData.currencyItems() {
      currencyArray.append(contentsOf: item.item)
    }
    
  }
  @IBAction func compareToButton(_ sender: Any) {
    pickerviewVIEW.isHidden = false
  }
  
  func setChartValues(_ count : Int = 20) {
    let values = (0..<count).map { (i) -> ChartDataEntry in
      let val = Double(arc4random_uniform(UInt32(count)) + 3)
      return ChartDataEntry(x: Double(i), y: val)
    }
    
    let set1 = LineChartDataSet(values: values, label: "DataSet 1")
    let data = LineChartData(dataSet: set1)
    
    self.chartView.data = data
    
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

