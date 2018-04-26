//
//  CurrencyCell.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-12.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {

  @IBOutlet weak var currencyName: UILabel!
  @IBOutlet weak var currencyDescription: UILabel!
  @IBOutlet weak var symbol: UILabel!
  @IBOutlet weak var currencySymbol: UILabel!
  @IBOutlet weak var rateLabel: UILabel!
  
  func configeureCell(currencyName: String, currencyDescription: String, currencyRate: String, flag: String, symbol: String) {

    self.symbol.text = symbol
    self.currencyName.text = currencyName
    self.currencyDescription.text = currencyDescription
    self.rateLabel.text = currencyRate
    self.currencySymbol.text = flag
    
  }
  
}
