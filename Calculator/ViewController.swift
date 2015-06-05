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

    var userIsInTheMiddleOfTypingANumber: Bool = false {
        didSet {
            let clearButtonTitle = userIsInTheMiddleOfTypingANumber ? "C" : "AC"
            clearButton.setTitle(clearButtonTitle, forState: UIControlState.Normal)
        }
    }
    var operandStack = [Double]()

    // The value of the calculator display, as a Double?
    var displayValue: Double? {
        get {
            let number = NSNumberFormatter().numberFromString(display.text!)
            return number?.doubleValue
        }
        set { println("displayValue=\(displayValue)")
            display.text = (newValue ?? 0.0) == 0 ? "0" : "\(newValue!)" // Convert nil and 0.0 to "0"
        }
    }

    
    // A number was pressed
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!

        if digit == "." && display.text!.rangeOfString(".") != nil {
            return
        }
        
        if userIsInTheMiddleOfTypingANumber {
            display.text = (display.text! == "0" ? digit : display.text! + digit)
        } else {
            display.text = digit
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
        }
    }
    
    
    // Perform a unary operation
    private func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    
    // Performs a unary operation on an argument instead of the stack                // For +/-
    private func performOperation(operand: Double, operation: Double -> Double) {
        displayValue = operation(operand)
        if !userIsInTheMiddleOfTypingANumber {
            enter()
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
            println("operandStack = \(operandStack)")
        }
            displayValue = 0
    }
}

