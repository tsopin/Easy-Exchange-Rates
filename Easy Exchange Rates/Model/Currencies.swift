//
//  Currencies.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-12.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit
import SwiftyJSON

// COUNTRIES MODEL
struct Results: Codable {
  let results: [String: Country]
  
  init(results: [String: Country]) {
    self.results = results
  }
}
struct Country: Codable {
  
  let currencyId: String
  let currencyName: String
  let currencySymbol: String?
  let id: String
  let name: String
  
  
  init(currencyId :String, currencyName: String, currencySymbol: String, id: String, name: String ) {
    
    self.currencyId = currencyId
    self.currencyName = currencyName
    self.currencySymbol = currencySymbol
    self.id = id
    self.name = name
    
  }
}


struct Rate {
  let base: String
  let several: String
  let rate: Double
}

struct CurrencyRate: Codable {
  
 
  
}


//struct CurrencyRate: Codable {
//
//  let USD_AFN : Double
//  let USD_AUD : Double
//  let USD_BDT : Double
//  let USD_BRL : Double
//  let USD_KHR : Double
//
//  init(USD_AFN: Double, USD_BDT: Double, USD_AUD: Double, USD_BRL: Double, USD_KHR: Double) {
//
//    self.USD_AFN = USD_AFN
//    self.USD_AUD = USD_AUD
//    self.USD_BDT = USD_BDT
//    self.USD_BRL = USD_BRL
//    self.USD_KHR = USD_KHR
//
//  }

//}

//let chosenCurrency = "AUD"
//
//struct CurrencyResponse: Decodable {
//  let name:String
//  let symbol:String
//  let price:String
//  private static var priceKey:String {
//    return "USD_\(chosenCurrency)"
//  }
//
//  private enum SimpleCodingKeys: String, CodingKey {
//    case name, symbol
//  }
//
//  private struct PriceCodingKey : CodingKey {
//    var stringValue: String
//    init?(stringValue: String) {
//      self.stringValue = stringValue
//    }
//    var intValue: Int?
//    init?(intValue: Int) {
//      return nil
//    }
//  }
//
//  init(from decoder:Decoder) throws {
//    let values = try decoder.container(keyedBy: SimpleCodingKeys.self)
//    name = try values.decode(String.self, forKey: .name)
//    symbol = try values.decode(String.self, forKey: .symbol)
//    let priceValue = try decoder.container(keyedBy: PriceCodingKey.self)
//    price = try priceValue.decode(String.self, forKey: PriceCodingKey(stringValue:CurrencyResponse.priceKey)!)
//  }
//}






















