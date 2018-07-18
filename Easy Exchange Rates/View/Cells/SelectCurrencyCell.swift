//
//  SelectCurrencyCell.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-16.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit

class SelectCurrencyCell : UITableViewCell {
  
  @IBOutlet weak var flagView: UILabel!
  @IBOutlet weak var countryNameLabel: UILabel!
  @IBOutlet weak var currencyNameLabel: UILabel!
  @IBOutlet weak var currencySymbol: UILabel!
  @IBOutlet weak var currencyCode: UILabel!
  
  func configureCell(flag: String, countryName: String, currencyName: String, symbol: String, currencyCode: String) {
    
    self.flagView.text = flag
    self.countryNameLabel.text = countryName
    self.currencyNameLabel.text = currencyName
    self.currencySymbol.text = symbol
    self.currencyCode.text = currencyCode
    
  }
}
