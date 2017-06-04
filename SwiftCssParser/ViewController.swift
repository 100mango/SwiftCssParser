//
//  ViewController.swift
//  SwiftCssParser
//
//  Created by Mango on 2017/5/30.
//  Copyright © 2017年 Mango. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sizeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColorCSS = ("#View","color")
        
        self.sizeLabel.text = "\(SwiftDeviceCss.size(selector: "#View", key: "size"))"
    }


    @IBAction func changeColor(_ sender: UIButton) {
        if SwiftCssTheme.theme == .day {
            SwiftCssTheme.theme = .night
        } else {
            SwiftCssTheme.theme = .day
        }
    }

}

