//
//  CurrencyCell.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-12.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {


  @IBOutlet weak var currencyImage: UIImageView!
  @IBOutlet weak var currencyName: UILabel!
  @IBOutlet weak var currencyDescription: UILabel!
  
  func configeureCell(currencyName: String, currencyDescription: String, currencyImage: UIImage) {

    self.currencyImage.image = currencyImage
    self.currencyName.text = currencyName
    self.currencyDescription.text = currencyDescription
    
  }

}
