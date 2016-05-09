//
//  ViewController.swift
//  Sample
//
//  Created by Magic on 9/5/2016.
//  Copyright © 2016 Magic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteColor()
        title = "Sample"
        
        view.addSubview(tBt)
        tBt.center = view.center
    }
    
    lazy var tBt: SMBloomBtn = {
        let bt = SMBloomBtn()
        return bt
    }()
}

