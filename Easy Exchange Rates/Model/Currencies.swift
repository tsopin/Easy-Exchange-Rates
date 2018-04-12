//
//  Currencies.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-12.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit

class Currencies {
  
  var code: String
  var description: String
  var image: UIImage
  
  init(code: String, description: String, image: UIImage){
    self.code = code
    self.description = description
    self.image = image
  }
}
