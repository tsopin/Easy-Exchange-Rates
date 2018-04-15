//
//  CurrencyData.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-12.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit

class CurrencyData {
  
  static let instance = CurrencyData()
  
  
  var usRate = Double()

  private let currencyList = [

    Currencies(code: "USA", description: "US Dollar", image: "US_Flag.png", rate: "123.3"),
    Currencies(code: "CAD", description: "Canadian Dollar", image: "Canada_Flag.png", rate: "212.2"),
    Currencies(code: "RUR", description: "Russian Rouble", image: "Russia_Flag.png", rate: "564.3"),
    Currencies(code: "EUR", description: "Euro", image: "Euro_Flag.png", rate: "112.2"),
    Currencies(code: "GBP", description: "British Pound Sterling", image: "GB_Flag.png", rate: "1222.2")

  ]

  func getCurrencies() -> [Currencies] {
    return currencyList
  }
}












  
  //
  //  var item: [Currencies]
  //
  //  init(item: [Currencies]) {
  //    self.item = item
  //  }
  //
  //  static func currencyItems() -> [CurrencyData]{
  //    return [CurrencyData.currencySet()]
  //  }
  //
  //  static func currencySet() -> CurrencyData {
  //
  //    var currencyItems = [Currencies]()
  //
  //    currencyItems.append(Currencies(code: "USD", description: "US Dollar", image: UIImage(named: "US_Flag.png")!, rate: 12.2))
  //    currencyItems.append(Currencies(code: "CAD", description: "Canadian Dollar", image: UIImage(named: "Canada_Flag.png")!, rate: 212.2))
  //    currencyItems.append(Currencies(code: "RUR", description: "Russian Rouble", image: UIImage(named: "Russia_Flag.png")!, rate: 152.2))
  //    currencyItems.append(Currencies(code: "EUR", description: "Euro", image: UIImage(named: "Euro_Flag.png")!, rate: 112.2))
  //    currencyItems.append(Currencies(code: "GBP", description: "British Pound Sterling", image: UIImage(named: "GB_Flag.png")!, rate: 1222.2))
  //
  //    return CurrencyData(item: currencyItems)
  //  }
  

