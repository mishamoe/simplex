//
//  Plan.swift
//  simplex
//
//  Created by Михаил on 09.12.15.
//  Copyright © 2015 Михаил. All rights reserved.
//

import UIKit

class Plan: NSObject {
    var values: [Double]
    
    init(values: [Double]) {
        self.values = values
    }
    
    func getDescription() -> String {
        var description = ""
        
        for (index, value) in values.enumerate() {
            let intIndex = Int(index+1)
            description += "x\(intIndex)=\(value), "
        }
        
        return String(description.characters.dropLast(2))
    }
}
