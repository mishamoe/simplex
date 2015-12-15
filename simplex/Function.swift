//
//  Function.swift
//  simplex
//
//  Created by Михаил on 30.11.15.
//  Copyright © 2015 Михаил. All rights reserved.
//

import UIKit

class Function: BaseType {
    
    init(stringFunction: String) {
        super.init()
        self.stringRepresentation = stringFunction
        handleOperands(stringFunction)
    }
    
    func compute(plan: Plan) -> Double? {
        //Если количество переданных значений больше количества операндов,
        //то эти значения не учитываются (Xn=0)
        if plan.values.count >= operands.count {
            var result: Double = 0
            for (i, operand) in operands.enumerate() {
                result += operand.coefficient * plan.values[i]
            }
            return result
        }
        return nil
    }
}
