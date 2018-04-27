//
//  Service.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-14.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit
import Charts

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
class DigitValueFormatter : NSObject, IValueFormatter {
  
  func stringForValue(_ value: Double,
                      entry: ChartDataEntry,
                      dataSetIndex: Int,
                      viewPortHandler: ViewPortHandler?) -> String {
    let valueWithoutDecimalPart = String(format: "%.2f", value)
    return "\(valueWithoutDecimalPart)"
  }
}

