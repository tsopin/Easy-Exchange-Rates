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
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  
  var countryArray = [Country]()
  var addedCountries = [Country]()
  var filtredCountryArray = [Country]()
  var choosenCountryArray = [Country]()
  var delegate: AddNewCurrencyDelegate?
  let searchController = UISearchController(searchResultsController: nil)
  let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ChosenCurrencies.plist")
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector:#selector(AddCurrencyVC.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector:#selector(AddCurrencyVC.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    selectTableView.delegate = self
    selectTableView.dataSource = self
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Find by Country or Currency Name"
    
    navigationItem.searchController = searchController
    navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
    navigationItem.hidesSearchBarWhenScrolling = false
    definesPresentationContext = true
    
    getCountryList()
    loadUserCurrencies()
    
    countryArray = countryArray.filter { !addedCountries.contains($0) } //Filter array of Countries by already added countries
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    searchController.isActive = false
  }
  
  func loadUserCurrencies() {
    
    if let data = try? Data(contentsOf: dataFilePath!) {
      let decoder = PropertyListDecoder()
      do {
        addedCountries = try decoder.decode([Country].self, from: data)
      } catch {
        print("Error \(error)")
      }
    }
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
  
  // MARK: Search
  
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text!)
  }
  
  func filterContentForSearchText(_ searchText: String, scope: String = "All") {
    filtredCountryArray = countryArray.filter({ (country: Country) -> Bool in
      return country.name.lowercased().contains(searchText.lowercased()) || country.currencyId.lowercased().contains(searchText.lowercased()) || country.currencyName.lowercased().contains(searchText.lowercased())
    })
    selectTableView.reloadData()
  }
  
  func isFiltering() -> Bool {
    return searchController.isActive && !(searchController.searchBar.text?.isEmpty)!
  }
  
  deinit {
  }
  
  func alert(message: String) {
    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
    //    searchController.searchBar.text = ""
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
    let country = isFiltering() ? filtredCountryArray[indexPath.row] : countryArray[indexPath.row]
    var symbol = String()
    let countryName = country.name
    let currencyCode = country.currencyId
    let description = country.currencyName
    let getFlag = Service.instance.flag(country: country.id)
    
    if country.currencySymbol != nil {
      symbol = country.currencySymbol!
    } else {
      symbol = ""
    }
    
    cell.configeureCell(flag: getFlag, countryName: countryName, currencyName: description, symbol: symbol, currencyCode: currencyCode)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let country: Country
    
//    Checking if USD or EUR already exist in the list
    if isFiltering() {
      
      if  filtredCountryArray[indexPath.row].currencyName == "European euro" && addedCountries.contains(where: { $0.currencyName == "European euro" }) {
        
        alert(message: "Euro already exist in your list")
        
      } else if filtredCountryArray[indexPath.row].currencyId == "USD" && addedCountries.contains(where: { $0.currencyId == "USD"}) {
        
        alert(message: "United States dollar already exist in your list")
        
      } else {
        country = filtredCountryArray[indexPath.row]
        delegate?.userAddNewCurrency(currency: country)
        navigationController?.popToRootViewController(animated: true)
        navigationController?.dismiss(animated: true, completion: nil)
      }
      
    } else {
      
      if countryArray[indexPath.row].currencyId == "EUR" && addedCountries.contains(where: { $0.currencyId == "EUR"}) {
        
        alert(message: "Euro already exist in your list")
        
      } else if countryArray[indexPath.row].currencyId == "USD" && addedCountries.contains(where: { $0.currencyId == "USD"}) {
        
        alert(message: "United States dollar already exist in your list")
        
      } else {
        country = countryArray[indexPath.row]
        delegate?.userAddNewCurrency(currency: country)
        navigationController?.popToRootViewController(animated: true)
        navigationController?.dismiss(animated: true, completion: nil)
      }
    }
  }
  
//  Move uitableView above a keyboard
  @objc func keyboardWillShow(notification : NSNotification) {
    
    let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
    self.bottomConstraint.constant = keyboardSize.height
    UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
      
    })
  }
  
  @objc func keyboardWillHide(notification : NSNotification) {
    self.bottomConstraint.constant = 0
  }
}

