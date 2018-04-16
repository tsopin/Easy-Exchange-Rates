////
////  CurrencyData.swift
////  Easy Exchange Rates
////
////  Created by Timofei Sopin on 2018-04-12.
////  Copyright © 2018 Timofei Sopin. All rights reserved.
////
//
//import UIKit
//
//
//
//  struct Results: Codable {
//
//    let currency: [String: CurrencyItem]
//    
//    enum CodingKeys: String, CodingKey {
//      case currency
//    }
//  }
//  
//  struct CurrencyItem: Codable {
//    let currencyId: String
//    let currencyName: String
//    let currencySymbol: String
//    let id: String
//    let name: String
//    
//    enum CodingKeys: String, CodingKey {
//      case currencyId
//      case currencyName
//      case currencySymbol
//      case id
//      case name
//    }
//  }
//  
//
//
//  
//  
//  
//
//
//
//
//
//
//
//
//
//
//
//
//  
//  //
//  //  var item: [Currencies]
//  //
//  //  init(item: [Currencies]) {
//  //    self.item = item
//  //  }
//  //
//  //  static func currencyItems() -> [CurrencyData]{
//  //    return [CurrencyData.currencySet()]
//  //  }
//  //
//  //  static func currencySet() -> CurrencyData {
//  //
//  //    var currencyItems = [Currencies]()
//  //
//  //    currencyItems.append(Currencies(code: "USD", description: "US Dollar", image: UIImage(named: "US_Flag.png")!, rate: 12.2))
//  //    currencyItems.append(Currencies(code: "CAD", description: "Canadian Dollar", image: UIImage(named: "Canada_Flag.png")!, rate: 212.2))
//  //    currencyItems.append(Currencies(code: "RUR", description: "Russian Rouble", image: UIImage(named: "Russia_Flag.png")!, rate: 152.2))
//  //    currencyItems.append(Currencies(code: "EUR", description: "Euro", image: UIImage(named: "Euro_Flag.png")!, rate: 112.2))
//  //    currencyItems.append(Currencies(code: "GBP", description: "British Pound Sterling", image: UIImage(named: "GB_Flag.png")!, rate: 1222.2))
//  //
//  //    return CurrencyData(item: currencyItems)
//  //  }
//  
//
