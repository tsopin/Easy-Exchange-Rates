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
  @IBOutlet weak var backgroundCellView: UIView!
  @IBOutlet weak var currencyDescription: UILabel!
  @IBOutlet weak var symbol: UILabel!
  @IBOutlet weak var currencyFlag: UILabel!
  @IBOutlet weak var rateLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  
    
    self.backgroundCellView.layer.cornerRadius = 8
//    self.backgroundCellView.layer.masksToBounds = true
    self.backgroundCellView.addShadow(color: UIColor.lightGray, radius: 2)
   
  }
  
  func configureCell(currencyName: String, currencyDescription: String, currencyRate: String, flag: String, symbol: String, isSelected: Bool) {
 
    if isSelected {
      self.backgroundCellView.layer.borderWidth = 2
      self.backgroundCellView.layer.borderColor = Colors.init().mainColor.cgColor
    } else {
      self.backgroundCellView.layer.borderWidth = 0
    }
    

    self.symbol.text = symbol
    self.currencyName.text = currencyName
    self.currencyDescription.text = currencyDescription
    self.rateLabel.text = currencyRate
    self.currencyFlag.text = flag
    
  }
}
