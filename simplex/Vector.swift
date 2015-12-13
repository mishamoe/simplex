//
//  Vector.swift
//  simplex
//
//  Created by Михаил on 30.11.15.
//  Copyright © 2015 Михаил. All rights reserved.
//

import UIKit

class Vector: NSObject {
    var coefficients: [Double] = [Double]()
    var index: Int = 0
    
    override init() {
        super.init()
    }
    
    init(coefficients: [Double]) {
        self.coefficients = coefficients
    }
    
    func addCoefficient(coef: Double) {
        coefficients.append(coef)
    }
    
    func getDescription() -> String {
        var description: String = ""
        
        description += "A[\(index)] => ["
        
        for coefficient in coefficients {
            description += String(coefficient) + ", "
        }
        
        description = String(description.characters.dropLast(2))
        description += "]"
        
        return description
    }
}
