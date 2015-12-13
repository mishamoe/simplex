//
//  UserInput.swift
//  simplex
//
//  Created by Михаил on 07.12.15.
//  Copyright © 2015 Михаил. All rights reserved.
//

import UIKit

class UserInput: NSObject {
    var function: Function
    var searchParameter: SearchParameter
    var vectorSet: VectorSet
    var setOfEquations: SetOfEquations
    
    init(function: String, searchParameter: Int, equations: [String]) {
        // Function
        self.function = Function(stringFunction: function)
        
        // Search Parameter
        self.searchParameter = SearchParameter(rawValue: searchParameter)!
        
        // Vector Set
        //Default value for equations
        let defaultEquations: [String] = [
            "-1x1-1x2-2x3+1x4+0x5+0x6=5",
            "+2x1-3x2+1x3+0x4+1x5+0x6=3",
            "+2x1-5x2+6x3+0x4+0x5+1x6=5"
        ]

        self.setOfEquations = SetOfEquations()
        for stringEquation in defaultEquations {
            if let equation = Equation(stringEquation: stringEquation) {
                self.setOfEquations.addEquation(equation)
            }
        }
        self.vectorSet = VectorSet(set: self.setOfEquations)
    }
}
