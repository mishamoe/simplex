//
//  SetOfEquations.swift
//  simplex
//
//  Created by Михаил on 30.11.15.
//  Copyright © 2015 Михаил. All rights reserved.
//

import UIKit

class SetOfEquations: NSObject {
    var equations: [Equation] = [Equation]()
    
    func addEquation(equation: Equation) {
        equations.append(equation)
    }
}
