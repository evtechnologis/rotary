//
//  SMRotaryProtocol.swift
//  RotaryWheel
//
//  Created by zhaofei on 2015-09-14.
//  Copyright © 2015 zhaofei. All rights reserved.
//

import Foundation
import UIKit

protocol SMRotaryProtocol {
    var sectorLabel: UILabel {get set}
    // protocol definition goes here
    func wheelDidChangeValue(newValue: String ) -> Void
}

