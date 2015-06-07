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
    var operandStack = [Double]()
    var currentOperation = ""

    // The value of the calculator display, as a `Double?`
    var displayValue: Double? {
        get {
            let number = NSNumberFormatter().numberFromString(display.text!)
            return number?.doubleValue
        }
        set {
            display.text = (newValue ?? 0.0) == 0 ? "0" : "\(newValue!)" // Convert nil and 0.0 to "0"
            println("displayValue=\(displayValue)")
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
        if userIsInTheMiddleOfTypingANumber && sender.currentTitle! != "⁺/-" {  // For +/-
            enter()
        }

        currentOperation = sender.currentTitle!
        
        switch sender.currentTitle! {
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $0 - $1 }
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $0 / $1 }
        case "√": performOperation { sqrt($0) }
        case "sin": performOperation { sin($0) }
        case "cos": performOperation { cos($0) }
        case "⁺/-":
            if userIsInTheMiddleOfTypingANumber {
                performOperation(displayValue!) { -$0 }
            } else {
                performOperation { -$0 }
            }
        default:
            break
        }
        
        
    }
    
    
    // Perform a binary operation
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            let b = operandStack.removeLast()
            let a = operandStack.removeLast()
            displayValue = operation(a, b)
            enter()
            addToHistory(operation: currentOperation, operands: a, b)
        }
    }
    
    
    // Perform a unary operation
    private func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            let a = operandStack.removeLast()
            displayValue = operation(a)
            enter()
            addToHistory(operation: currentOperation, operands: a)
        }
    }
    
    
    // Performs a unary operation on an argument instead of the stack                // For +/-
    private func performOperation(operand: Double, operation: Double -> Double) {
        displayValue = operation(operand)
        if !userIsInTheMiddleOfTypingANumber {
            enter()
        }
    }
    
    
    // Adds operation to history printout
    func addToHistory(#operation: String, operands: Double...) {
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
        operandStack.append(displayValue!)
        userIsInTheMiddleOfTypingANumber = false
        println("operandStack = \(operandStack)")
    }
    
    
    // Clear or Clear All button was pressed
    @IBAction func clear(sender: UIButton) {
        if sender.currentTitle! == "AC" {
            operandStack.removeAll()
            history.text = ""
            println("operandStack = \(operandStack)")
        }
        displayValue = 0
        userIsInTheMiddleOfTypingANumber = false
    }
}

