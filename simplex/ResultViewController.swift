//
//  ResultViewController.swift
//  simplex
//
//  Created by Михаил on 09.12.15.
//  Copyright © 2015 Михаил. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    @IBOutlet weak var resultTextField: UITextView!

    var outputGenerator: OutputGenerator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let outputGenerator = self.outputGenerator {
            let attributedText = NSMutableAttributedString()
            attributedText.appendAttributedString(outputGenerator.getInputData())
            attributedText.appendAttributedString(outputGenerator.getOutputData())
            
            resultTextField.attributedText = attributedText
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
