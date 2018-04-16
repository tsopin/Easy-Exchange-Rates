//
//  Service.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-14.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Service {
  
  static let instance = Service()
  
  func flag(country:String) -> String {
    let base : UInt32 = 127397
    var s = ""
    for v in country.unicodeScalars {
      s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
  }
  
  
  
  
  
  
  
  
  
  
  
}
