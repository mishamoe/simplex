//
//  Operand.swift
//  simplex
//
//  Created by Михаил on 30.11.15.
//  Copyright © 2015 Михаил. All rights reserved.
//

import UIKit

class Operand: NSObject {
    var coefficient: Double = 0
    var index: Int = 0
    
    init(coefficient: Double, index: Int) {
        self.coefficient = coefficient
        self.index = index
    }
    
    convenience init?(operand: String) {
        if let i = operand.characters.indexOf("x") {
            let coefficient = operand.substringToIndex(i)
            let index = operand.substringFromIndex(i.successor())
            if let doubleCoefficient = Double(coefficient), let intIndex = Int(index) {
                self.init(coefficient: doubleCoefficient, index: intIndex)
            } else {
                return nil
            }
        }else{
            return nil
        }
    }
}
