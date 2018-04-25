//
//  ExchangeVC.swift
//  Easy Exchange Rates
//
//  Created by Timofei Sopin on 2018-04-23.
//  Copyright © 2018 Timofei Sopin. All rights reserved.
//

import UIKit

class ExchangeVC: UIViewController {

  @IBOutlet weak var baseTextField: UITextField!
  
  @IBOutlet weak var compareToTextfield: UITextField!
  
  
  override func viewDidLoad() {
        super.viewDidLoad()
    baseTextField.becomeFirstResponder()
    
    }

}
