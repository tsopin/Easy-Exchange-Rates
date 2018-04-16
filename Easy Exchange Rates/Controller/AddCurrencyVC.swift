//
//  AddCurrencyVC.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-16.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit

protocol AddNewCurrencyDelegate {
  func userAddNewCurrency(currency: [Country])
}

class AddCurrencyVC: UIViewController {

  @IBOutlet weak var selectTableView: UITableView!
  
  var countryArray = [Country]()
  var choosenCountryArray = [Country]()
  var delegate: AddNewCurrencyDelegate?
  
  
  
  override func viewDidLoad() {
        super.viewDidLoad()
    choosenCountryArray.removeAll()
    selectTableView.delegate = self
    selectTableView.dataSource = self
    getCountryList()

    }
  
  
  func getCountryList(){
    let decoder = JSONDecoder()
    let file = Bundle.main.url(forResource: "currencyList", withExtension: "json")
    do {
      let ooo = try Data(contentsOf: file!)
      let results = try decoder.decode(Results.self, from: ooo)
      for (_, value) in results.results {
        self.countryArray.append(value)
      }
      self.countryArray = self.countryArray.sorted(by: { $0.name < $1.name })
      DispatchQueue.main.async {
        self.selectTableView.reloadData()
      }
//              print("ARRAY \(self.countryArray)")
    } catch {
      print("eerrro")
    }
    
  }
  

  @IBAction func doneButton(_ sender: Any) {
    
//
    
    print(choosenCountryArray.count)
    
    
  }
  
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  
}




extension AddCurrencyVC: UITableViewDelegate, UITableViewDataSource {
  

  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
    
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return countryArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = selectTableView.dequeueReusableCell(withIdentifier: "selectCurrencyCell") as! SelectCurrencyCell
    let country = countryArray[indexPath.row]

    var goSymbol = String()
    
    let countryName = country.name
    let currencyCode = country.currencyId
    let description = country.currencyName
    
    if country.currencySymbol != nil {
      goSymbol = country.currencySymbol!
    } else {
      goSymbol = ""
    }
    
    
    let getFlag = Service.instance.flag(country: country.id)
    
    
    cell.configeureCell(flag: getFlag, countryName: countryName, currencyName: description, symbol: goSymbol, currencyCode: currencyCode)
    
    return cell
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let country = countryArray[indexPath.row]
    
    choosenCountryArray.append(country)
    
    delegate?.userAddNewCurrency(currency: choosenCountryArray)
//    presentStoryboard()
    dismiss(animated: true, completion: nil)
    
    
  }
  
}

