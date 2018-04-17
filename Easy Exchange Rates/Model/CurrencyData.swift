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

struct GenericCodingKeys: CodingKey {
  var intValue: Int?
  var stringValue: String
  
  init?(intValue: Int) { self.intValue = intValue; self.stringValue = "\(intValue)" }
  init?(stringValue: String) { self.stringValue = stringValue }
  
  static func makeKey(name: String) -> GenericCodingKeys {
    return GenericCodingKeys(stringValue: name)!
  }
}

struct MyModel: Decodable {

  var values: [String: String]
  
  private enum CodingKeys: String, CodingKey {

    case values
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    values = [String: String]()
    let subContainer = try container.nestedContainer(keyedBy: GenericCodingKeys.self, forKey: .values)
    for key in subContainer.allKeys {
      values[key.stringValue] = try subContainer.decode(String.self, forKey: key)
    }
  }
}
