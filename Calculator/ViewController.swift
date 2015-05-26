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

        switch sender.titleLabel! {
        case "+": performOperation({ (a: Double, b: Double) -> Double in
            return a + b
        })
        case "−":
            mathFunction = subtract
        case "×":
            mathFunction = multiply
        case "÷":
            mathFunction = divide
        default:
            break
        }
        
        
    }
    
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            let a = operandStack.removeLast()
            let b = operandStack.removeLast()
            displayValue = operation(a, b)
            enter()
        }
    }
    
    
    // Math functions
    func divide(a: Double, b: Double) -> Double     { return a / b }
    func multiply(a: Double, b: Double) -> Double   { return a * b }
    func add(a: Double, b: Double) -> Double        { return a + b }
    func subtract(a: Double, b: Double) -> Double   { return a - b }
    
    // Enter button was pressed
    @IBAction func enter() {
        operandStack.append(displayValue)
        userIsInTheMiddleOfTypingANumber = false
        println("operandStack = \(operandStack)")
    }
    
}

