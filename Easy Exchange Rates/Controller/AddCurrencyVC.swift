//
//  AddCurrencyVC.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-16.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit

protocol AddNewCurrencyDelegate {
  func userAddNewCurrency(currency: Country)
}

class AddCurrencyVC: UIViewController, UISearchResultsUpdating {
  
  
  @IBOutlet weak var selectTableView: UITableView!
  
  var countryArray = [Country]()
  var filtredCountryArray = [Country]()
  var choosenCountryArray = [Country]()
  var delegate: AddNewCurrencyDelegate?
  let searchController = UISearchController(searchResultsController: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    selectTableView.delegate = self
    selectTableView.dataSource = self
    
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Find by name and select"
    
    navigationItem.searchController = searchController
    navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
    navigationItem.hidesSearchBarWhenScrolling = false
    definesPresentationContext = false
    
    getCountryList()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if searchController.canBecomeFirstResponder {
      searchController.becomeFirstResponder()
    }
  }
  
  func getCountryList(){
    let decoder = JSONDecoder()
    let file = Bundle.main.url(forResource: "currencyList", withExtension: "json")
    do {
      let list = try Data(contentsOf: file!)
      let results = try decoder.decode(Results.self, from: list)
      for (_, value) in results.results {
        self.countryArray.append(value)
      }
      self.countryArray = self.countryArray.sorted(by: { $0.name < $1.name })
      DispatchQueue.main.async {
        self.selectTableView.reloadData()
      }
    } catch {
      print("eerrro")
    }
    
  }
  
  
  @IBAction func doneButton(_ sender: Any) {
    
    //
    
    print(choosenCountryArray.count)
    
    
  }
  
  
  @IBAction func cancelButton(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  
  
  // MARK: -- Search --
  
  
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
  
  // search in email or username
  func filterContentForSearchText(_ searchText: String, scope: String = "All") {
    filtredCountryArray = countryArray.filter({ (country: Country) -> Bool in
      return country.name.lowercased().contains(searchText.lowercased()) || country.currencyId.lowercased().contains(searchText.lowercased()) || country.currencyName.lowercased().contains(searchText.lowercased())
    })
    selectTableView.reloadData()
  }
  
  // check if currently performing search to update table view accordingly
  func isFiltering() -> Bool {
    return searchController.isActive && !(searchController.searchBar.text?.isEmpty)!
  }
  
  deinit {
  }
}




extension AddCurrencyVC: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
    
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering() {
      return filtredCountryArray.count
    } else {
      return countryArray.count
    }
    
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = selectTableView.dequeueReusableCell(withIdentifier: "selectCurrencyCell") as! SelectCurrencyCell
    //    let country = countryArray[indexPath.row]
    let country = isFiltering() ? filtredCountryArray[indexPath.row] : countryArray[indexPath.row]
    
    var symbol = String()
    
    let countryName = country.name
    let currencyCode = country.currencyId
    let description = country.currencyName
    
    if country.currencySymbol != nil {
      symbol = country.currencySymbol!
    } else {
      symbol = ""
    }
    
    
    let getFlag = Service.instance.flag(country: country.id)
    
    
    cell.configeureCell(flag: getFlag, countryName: countryName, currencyName: description, symbol: symbol, currencyCode: currencyCode)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let country: Country
    
    if isFiltering() {
      
      country = filtredCountryArray[indexPath.row]
      delegate?.userAddNewCurrency(currency: country)
      
    } else {
      
      country = countryArray[indexPath.row]
      delegate?.userAddNewCurrency(currency: country)
      
    }
    
    navigationController?.popToRootViewController(animated: true)
    navigationController?.dismiss(animated: true, completion: nil)
    
  }
}

