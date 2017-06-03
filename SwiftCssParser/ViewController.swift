//
//  ViewController.swift
//  SwiftCssParser
//
//  Created by Mango on 2017/5/30.
//  Copyright © 2017年 Mango. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColorCSS = ("#View","color")
        
    }


    @IBAction func changeColor(_ sender: UIButton) {
        if SwiftCssTheme.theme == .day {
            SwiftCssTheme.theme = .night
        } else {
            SwiftCssTheme.theme = .day
        }
    }

}

