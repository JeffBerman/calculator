//
//  ViewController.swift
//  Calculator
//
//  Created by Jeff Berman on 5/22/15.
//  Copyright (c) 2015 Jeff Berman. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var history: UILabel!

    var userIsInTheMiddleOfTypingANumber: Bool = false {
        didSet {
            let clearButtonTitle = userIsInTheMiddleOfTypingANumber ? "C" : "AC"
            clearButton.setTitle(clearButtonTitle, forState: UIControlState.Normal)
        }
    }

    var brain = CalculatorBrain()

    // The value of the calculator display, as a `Double?`
    var displayValue: Double? {
        get {
            let number = NSNumberFormatter().numberFromString(display.text!)
            return number?.doubleValue
        }
        set {
            if let value = newValue {
                display.text = value == 0.0 ? "0" : "\(value)" // Prettify 0.0.
            } else {
                display.text = ""
            }
            
            print("displayValue = \(display.text)")
        }
    }

    
    // A number was pressed
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            if digit == "." && display.text!.rangeOfString(".") != nil {
                return
            }
            display.text = (display.text! == "0" ? digit : display.text! + digit)
        } else {
            display.text = (digit == ".") ? "0" + digit : digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }

    
    // Operand (math symbol constant) button was pressed
    @IBAction func operand(sender: UIButton) {
        func performOperand(operand: Double) {
            displayValue = operand
            userIsInTheMiddleOfTypingANumber = true
        }
        
        switch sender.currentTitle! {
            case "π": performOperand(M_PI)
        default:
            break
        }
    }
    
    
    // Operator button was pressed
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
        }
    }
    
    
    // Adds operation to history printout
    func addToHistory(operation operation: String, operands: Double...) {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 15

        if operands.count == 1 {
            history.text = history.text! + "\n\n\(operation)(" + formatter.stringFromNumber(operands[0])! + ")"
            history.text = history.text! + "\n= " + formatter.stringFromNumber(displayValue!)!
        } else if operands.count == 2 {
            history.text = history.text! + "\n\n\(operands[0]) \(operation) \(operands[1])"
            history.text = history.text! + "\n= " + formatter.stringFromNumber(displayValue!)!
        }
        
    }

    
    
    // Enter button was pressed
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let value = displayValue {
            displayValue = brain.pushOperand(value)
        }
    }
    
    
    // Clear or Clear All button was pressed
    @IBAction func clear(sender: UIButton) {
        if sender.currentTitle! == "AC" {
            brain.clearOperations()
        }
        displayValue = 0
        userIsInTheMiddleOfTypingANumber = false
    }
}

