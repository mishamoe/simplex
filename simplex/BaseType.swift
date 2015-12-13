//
//  BaseType.swift
//  simplex
//
//  Created by Михаил on 30.11.15.
//  Copyright © 2015 Михаил. All rights reserved.
//

import UIKit

class BaseType: NSObject {
    var operands: [Operand] = [Operand]()
    
    func handleOperands(operands: String) {
        //Разбиваем строку на операнды
        var operand: String = ""
        for character in operands.characters {
            switch character {
            case "+", "-":
                addOperand(operand)
                operand = ""
                operand.append(character)
            default:
                operand.append(character)
            }
        }
        //Добавляем последний операнд
        addOperand(operand)
    }
    
    func addOperand(stringOperand: String) {
        if let operand = Operand(operand: stringOperand) {
            operands.append(operand)
        }
    }
    
    func getOperandByIndex(index: Int) -> Operand {
        for operand in operands {
            if operand.index == index {
                return operand
            }
        }
        return Operand(coefficient: 0, index: index)
    }
}
