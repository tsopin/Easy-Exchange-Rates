//
//  Currencies.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-12.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit
import SwiftyJSON


class Currencies: Codable {
  
  var code: String
  var description: String
  var rate: String
  var image: String
  
  init(code: String, description: String, image: String, rate: String){
    
    self.code = code
    self.description = description
    self.image = image
    self.rate = rate
  }
}
