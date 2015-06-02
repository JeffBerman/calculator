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

    var userIsInTheMiddleOfTypingANumber: Bool = false
    var operandStack = [Double]()

    // The value of the calculator display, as a Double
    var displayValue: Double {
        get {
            let number = NSNumberFormatter().numberFromString(display.text!)
            return number!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            display.text = (display.text! == "0" ? digit : display.text! + digit)
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    
    // Operator button was pressed
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }

        switch sender.currentTitle! {
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $0 - $1 }
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $0 / $1 }
        case "√": performOperation { sqrt($0) }
        default:
            break
        }
        
        
    }
    
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            let b = operandStack.removeLast()
            let a = operandStack.removeLast()
            displayValue = operation(a, b)
            enter()
        }
    }
    
    
    private func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }

    
    
    // Enter button was pressed
    @IBAction func enter() {
        operandStack.append(displayValue)
        userIsInTheMiddleOfTypingANumber = false
        println("operandStack = \(operandStack)")
    }
    
}

