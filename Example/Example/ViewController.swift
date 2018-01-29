//
//  ViewController.swift
//  Example
//
//  Created by Luong Van Lam on 01/24/2018.
//  Copyright © 2018 lamlv. All rights reserved.
//

import UIKit
import StylesLoader

class ViewController: UIViewController {
    @IBOutlet weak var lblMain: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        lblMain.styles.loadStyles(".h1")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
