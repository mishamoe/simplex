//
//  ViewController.swift
//  simplex
//
//  Created by Михаил on 30.11.15.
//  Copyright © 2015 Михаил. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var functionTextField: UITextField!
    @IBOutlet weak var searchParameterSegmentedControl: UISegmentedControl!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    private var defaultTintColor: UIColor!
    private var userInput: UserInput?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        defaultTintColor = searchParameterSegmentedControl.tintColor
        functionTextField.text = "-1x1+3x2+2x3"
    }
    
    @IBAction func searchParameterValueChanged(sender: AnyObject) {
        searchParameterSegmentedControl.tintColor = defaultTintColor
    }
    
    @IBAction func clear(sender: UIBarButtonItem) {
        functionTextField.text = ""
        
        searchParameterSegmentedControl.selectedSegmentIndex = -1
        searchParameterSegmentedControl.tintColor = defaultTintColor
        
        for subview in stackView.arrangedSubviews {
            if let stack = subview as? UIStackView {
                if let textField = stack.arrangedSubviews[0] as? UITextField {
                    textField.text = ""
                }
            }
        }
    }
    
    @IBAction func addEquationToConstraints(sender: UIButton) {
        let stack = self.stackView
        let index = stack.arrangedSubviews.count - 1
        let addView = stack.arrangedSubviews[index]
        
        let scroll = self.scrollView
        let offset = CGPoint(x: scroll.contentOffset.x, y: scroll.contentOffset.y + addView.frame.size.height)
        
        let newView = createConstraint()
        newView.hidden = true
        stack.insertArrangedSubview(newView, atIndex: index)
        
        UIView.animateWithDuration(0.25) { () -> Void in
            newView.hidden = false
            scroll.contentOffset = offset
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {}
    
    private func createConstraint() -> UIView {
        // Text field
        let textField = UITextField()
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.placeholder = "Enter Equation"
        textField.font = UIFont.systemFontOfSize(14)
        textField.clearButtonMode = .WhileEditing

        // Delete Button
        let deleteButton = UIButton(type: .System)
        deleteButton.setTitle("Delete", forState: .Normal)
        deleteButton.addTarget(self, action: "deleteConstraint:", forControlEvents: .TouchUpInside)

        // Stack View
        let stack = UIStackView()
        stack.spacing = 20
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(deleteButton)
        
        return stack
    }
    
    private func deleteConstraint(sender: UIButton) {
        if let stack = sender.superview {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                stack.hidden = true
                }, completion: { (success) -> Void in
                    stack.removeFromSuperview()
            })
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "compute" {
            return handleUserInput()
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "compute" {
            if let userInput = self.userInput {
                if let navigationController = segue.destinationViewController as? UINavigationController {
                    if let resultViewController = navigationController.topViewController as? ResultViewController {
                        resultViewController.outputGenerator = OutputGenerator(userInput: userInput)
                    }
                }
            }
        }
    }
    
    private func handleUserInput() -> Bool {
        if let function = functionTextField.text where function.characters.count > 0 {
            let searchParameter = searchParameterSegmentedControl.selectedSegmentIndex
            if searchParameter != -1 {
                var equations: [String] = [String]()
                for subview in stackView.arrangedSubviews {
                    if let stack = subview as? UIStackView {
                        if let textField = stack.arrangedSubviews[0] as? UITextField {
                            if let text = textField.text where text.characters.count > 0 {
                                equations.append(text)
                            }
                        }
                    }
                }
                
                userInput = UserInput(function: function, searchParameter: searchParameter, equations: equations)
                return true
            } else {
                searchParameterSegmentedControl.tintColor = UIColor.redColor()
            }
        }
        
        return false
    }
}

