//
//  ViewController.swift
//  RotaryWheel
//
//  Created by zhaofei on 2015-09-14.
//  Copyright © 2015 zhaofei. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var sectoLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create sector label
        sectoLabel = UILabel(frame: CGRectMake(100, 350, 120, 30))
        sectoLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(sectoLabel)
        
        
        
        let wheel:SMRotaryWheel = SMRotaryWheel.init(frame: CGRectMake(0, 100, 300, 300), del: self, sectionsNum: 8)
        
        wheel.center = CGPoint(x: 160,y: 240)
        self.view.addSubview(wheel)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func wheelDidChangeValue(newValue:String) ->Void
    {
        self.sectoLabel.text = newValue
    }


}

