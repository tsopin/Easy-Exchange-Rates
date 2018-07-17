//
//  Fonts.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-07-16.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit

struct Fonts {
  
  let noDataFont: UIFont!
  let valueFont: UIFont!
  let legendFont: UIFont!
  
  init() {
    self.noDataFont = UIFont(name: "HelveticaNeue-Light", size: 20)!
    self.valueFont = UIFont(name: "HelveticaNeue-Light", size: 11)!
    self.legendFont = UIFont(name: "HelveticaNeue-Light", size: 15)!
  }
}
