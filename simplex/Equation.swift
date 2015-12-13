//
//  Equation.swift
//  simplex
//
//  Created by Михаил on 30.11.15.
//  Copyright © 2015 Михаил. All rights reserved.
//

import UIKit

class Equation: BaseType {
    var stringRepresentation: String
    var solution: Double = 0
    
    init?(stringEquation: String) {
        self.stringRepresentation = stringEquation
        super.init()
        //Если в уравнении нету символа "="
        if let index = stringEquation.characters.indexOf("=") {
            //Левая часть уравнения
            let leftSide = stringEquation.substringToIndex(index)
            
            handleOperands(leftSide)
            
            //Правая часть уравнения
            let rightSide = stringEquation.substringFromIndex(index.successor())
            if let solution = Double(rightSide) {
                self.solution = solution
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
