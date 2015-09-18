//
//  ViewController.swift
//  RotaryWheel
//
//  Created by zhaofei on 2015-09-14.
//  Copyright © 2015 zhaofei. All rights reserved.
//

import UIKit

class ViewController: UIViewController,SMRotaryProtocol {
    var valueLabel = UILabel()
    var delegate: SMRotaryProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create sector label
        valueLabel = UILabel(frame: CGRectMake((self.view.bounds.size.width / 2)-110, 10, 220, 50))

        valueLabel.textAlignment = NSTextAlignment.Center
        valueLabel.text = "Welcome to Schedule"
        valueLabel.textColor = UIColor.redColor()
        self.view.addSubview(valueLabel)
        
        
        
        let wheel:SMRotaryWheel = SMRotaryWheel.init(frame: CGRectMake(0, 0, 600, 600), del: self, sectionsNum: 9)
        
        wheel.center = CGPoint(x: 200,y: 320)
        self.view.addSubview(wheel)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func wheelDidChangeValue(newValue:String) ->Void
    {
        self.valueLabel.text = newValue
        
        print("(self.valueLabel.text) is Choosed.")
    }


}

