//
//  OutputGenerator.swift
//  simplex
//
//  Created by Михаил on 09.12.15.
//  Copyright © 2015 Михаил. All rights reserved.
//

import UIKit

class OutputGenerator: NSObject {
    let userInput: UserInput
    
    init(userInput: UserInput) {
        self.userInput = userInput
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
        
        // Initial plan
        let initialPlan = userInput.vectorSet.getInitialPlan()
        let initialPlanRow = generateMultilineRow("Initial plan:", content: initialPlan.getDescription())
        outputData.appendAttributedString(initialPlanRow)
        
        // Result of initial plan
        if let result = userInput.function.compute(initialPlan) {
            let initialPlanResult = generateMultilineRow("Result of initial plan: ", content: String(result))
            outputData.appendAttributedString(initialPlanResult)
        } else {
            let initialPlanResult = generateRow("Result of initial plan: ", content: "ERROR", color: UIColor.redColor())
            outputData.appendAttributedString(initialPlanResult)
            return outputData
        }
        
        // Marks for initial plan
        let marksForInitialPlan = generateRow("Marks for initial plan:", content: "")
        outputData.appendAttributedString(marksForInitialPlan)
        let marks = userInput.vectorSet.getMarks(userInput.function)
        let badVectorIndex = userInput.vectorSet.isOptimal(marks, parameter: userInput.searchParameter)
        
        for (index, mark) in marks.enumerate() {
            var color: UIColor?
            if let badIndex = badVectorIndex where badIndex == index {
                color = UIColor.redColor()
            }
            
            let markContent = "A[\(index)] => \(Int(mark))"
            let markRow = generateRow("\t", content: markContent, color: color)
            outputData.appendAttributedString(markRow)
        }
        
        outputData.appendAttributedString(NSAttributedString(string: "\n"))
        
        // Optimal plan
        let optimalPlan = userInput.vectorSet.findOptimalPlan(userInput.function, searchParameter: userInput.searchParameter)
        if let functionResult = userInput.function.compute(optimalPlan) {
            print("\(userInput.searchParameter.description()) value for function \(userInput.function.stringRepresentation) = \(functionResult)")
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
