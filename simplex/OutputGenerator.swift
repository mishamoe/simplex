//
//  OutputGenerator.swift
//  simplex
//
//  Created by Михаил on 09.12.15.
//  Copyright © 2015 Михаил. All rights reserved.
//

import UIKit

class OutputGenerator: NSObject {
    var userInput: UserInput!
    
    static var plansWithMarks = [[String : AnyObject]]()
    
    init(userInput: UserInput) {
        self.userInput = userInput
    }
    
    static func appendPlan(plan: Plan, marks: [Double]) {
        OutputGenerator.plansWithMarks.append(
            [
                "plan" : plan,
                "marks" : marks
            ]
        )
    }
    
    func getInputData() -> NSMutableAttributedString {
        let inputData = NSMutableAttributedString()
        
        let header = generateHeader("Input\n")
        inputData.appendAttributedString(header)
        
        // Function
        let functionRow = generateMultilineRow("Function: ", content: userInput.function.stringRepresentation)
        inputData.appendAttributedString(functionRow)
        
        // Search Parameter
        let searchParameterRow = generateMultilineRow("Search Parameter: ", content: userInput.searchParameter.description())
        inputData.appendAttributedString(searchParameterRow)
        
        // Set of constraints
        let constarintsRow = generateRow("Set of constraints:", content: "")
        inputData.appendAttributedString(constarintsRow)
        for equation in userInput.setOfEquations.equations {
            let equationRow = generateRow("\t", content: equation.stringRepresentation)
            inputData.appendAttributedString(equationRow)
        }
        
        return inputData
    }
    
    func getInputDataAnalysis() -> NSMutableAttributedString {
        let outputData = NSMutableAttributedString()
        
        let header = generateHeader("Output\n")
        outputData.appendAttributedString(header)
        
        // Vector representation
        let vectorRepresentation = generateRow("Vector representation:", content: "")
        outputData.appendAttributedString(vectorRepresentation)
        for vector in userInput.vectorSet.vectors {
            let vectorDescription = generateRow("\t", content: vector.getDescription())
            outputData.appendAttributedString(vectorDescription)
        }
        
        // Basis vectors
        var basisVectorContent = ""
        for vectorIndex in userInput.vectorSet.getBasisVectorsIndices() {
            basisVectorContent += "A[\(vectorIndex)], "
        }
        basisVectorContent = String(basisVectorContent.characters.dropLast(2))
        let basisVectorsRow = generateMultilineRow("Basis vectors: ", content: basisVectorContent)
        outputData.appendAttributedString(basisVectorsRow)
        
        // Basis variables
        var basisVariablesContent = ""
        for vectorIndex in userInput.vectorSet.getBasisVectorsIndices() {
            basisVariablesContent += "x\(vectorIndex), "
        }
        basisVariablesContent = String(basisVariablesContent.characters.dropLast(2))
        let basisVariables = generateMultilineRow("Basis variables: ", content: basisVariablesContent)
        outputData.appendAttributedString(basisVariables)
        
        // Free variables
        var freeVariablesContent = ""
        for vectorIndex in userInput.vectorSet.getNotBasisVectorsIndices() {
            freeVariablesContent += "x\(vectorIndex), "
        }
        freeVariablesContent = String(freeVariablesContent.characters.dropLast(2))
        let freeVariables = generateMultilineRow("Free variables: ", content: freeVariablesContent)
        outputData.appendAttributedString(freeVariables)
        outputData.appendAttributedString(NSAttributedString(string: "\n"))
        
        return outputData
    }
    
    func getOutputData() -> NSMutableAttributedString {
        let outputData = NSMutableAttributedString()
        
        userInput.vectorSet.findOptimalPlan(userInput.function, searchParameter: userInput.searchParameter)
        
        let plansWithMarks = OutputGenerator.plansWithMarks
        
        if plansWithMarks.count > 0 {
            for (index, planWithMarks) in plansWithMarks.enumerate() {
                if let plan = planWithMarks["plan"] as? Plan, let marks = planWithMarks["marks"] as? [Double] {
                    
                    let planHeaderText: String!
                    let planResultHeaderText: String!
                    let marksHeaderText: String!
                    
                    if index == 0 {
                        planHeaderText = "Plan #\(index+1) (initial):"
                        planResultHeaderText = "Result of plan #\(index+1) (initial): "
                        marksHeaderText = "Marks for plan #\(index+1) (initial):"
                    } else {
                        planHeaderText = "Plan #\(index+1):"
                        planResultHeaderText = "Result of plan #\(index+1): "
                        marksHeaderText = "Marks for plan #\(index+1):"
                    }
                    
                    // Plan
                    let planRow = generateMultilineRow(planHeaderText, content: plan.getDescription())
                    outputData.appendAttributedString(planRow)
                    
                    // Result of plan
                    if let result = userInput.function.compute(plan) {
                        let planResult = generateMultilineRow(planResultHeaderText, content: String(result))
                        outputData.appendAttributedString(planResult)
                    }
                    
                    // Marks for plan
                    let marksForPlan = generateRow(marksHeaderText, content: "")
                    outputData.appendAttributedString(marksForPlan)
                    
                    let badVectorIndex = userInput.vectorSet.isOptimal(marks, parameter: userInput.searchParameter)

                    for (index, mark) in marks.enumerate() {
                        var color: UIColor?
                        if let badIndex = badVectorIndex where badIndex == index {
                            color = UIColor.redColor()
                        }
                        
                        let markContent = "A[\(index)] => \(Double(mark))"
                        let markRow = generateRow("\t", content: markContent, color: color)
                        outputData.appendAttributedString(markRow)
                    }
                    
                    outputData.appendAttributedString(NSAttributedString(string: "\n"))
                }
            }
        }
        
        return outputData
    }
    
    private func generateHeader(title: String) ->NSAttributedString {
        return NSAttributedString(
            string: title,
            attributes: [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(18),
                NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue
            ]
        )
    }
    
    private func generateRow(label: String, content: String, color: UIColor?=nil) -> NSAttributedString {
        let row = NSMutableAttributedString()
        
        
        
        let rowTitle = NSAttributedString(string: label, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(14)])
        
        var contentAttributes: [String : AnyObject] = [String : AnyObject]()
        contentAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(14)
        if let fontColor = color {
            contentAttributes[NSForegroundColorAttributeName] = fontColor
        }
        
        let rowContent = NSAttributedString(string: content, attributes: contentAttributes)
        
        row.appendAttributedString(rowTitle)
        row.appendAttributedString(rowContent)
        row.appendAttributedString(NSAttributedString(string: "\n"))
        
        return row
    }
    
    private func generateMultilineRow(label: String, content: String, color: UIColor?=nil) -> NSAttributedString {
        let row = NSMutableAttributedString()
        
        let labelLine = generateRow(label, content: "", color: color)
        let contentLine = generateRow("\t", content: content, color: color)
        
        row.appendAttributedString(labelLine)
        row.appendAttributedString(contentLine)
        
        return row
    }
}
