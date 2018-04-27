//
//  Currencies.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-12.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit

// Countries Model
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

extension Country: Equatable {
  static func == (lhs: Country, rhs: Country) -> Bool {
    return lhs.name == rhs.name &&
      lhs.currencyId == rhs.currencyId
  }
}





















