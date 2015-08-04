//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Jeff Berman on 7/22/15.
//  Copyright (c) 2015 Jeff Berman. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    enum Op: CustomStringConvertible {
        case Operand(Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let symbol):
                        return symbol
                case .UnaryOperation(let operation, _):
                    return operation
                case .BinaryOperation(let operation, _):
                    return operation
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String:Double]() // Stores variables and their values
    
    var description: String {
        get {
            var (result, ops) = ("", opStack)
            repeat {
                var current: String?
                (current, ops) = description(ops)
                result = result == "" ? current! : "\(current!), \(result)"
            } while ops.count > 0
            return result
        }
    }
    
    // Used for recursive evaluation to generate the description
    func description(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (String(format: "%g", operand), remainingOps)
            case .Variable(let symbol):
                return (symbol, remainingOps)
            case .UnaryOperation(let symbol, _):
                let operandEvaluation = description(remainingOps)
                if let operand = operandEvaluation.result {
                    return ("\(symbol)(\(operand))", operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let operand1Evaluation = description(remainingOps)
                if let operand1 = operand1Evaluation.result {
                    let operand2Evaluation = description(operand1Evaluation.remainingOps)
                    if let operand2 = operand2Evaluation.result {
                        return ("\(operand2)\(symbol)\(operand1)", operand2Evaluation.remainingOps)
                    }
                }
            }
        }
        return ("?", ops)
    }
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("−", -))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("÷", /))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("⁺/-") { -$0 })
    }
    
    // Used for recursive evaluation
    func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let symbol):
                return (variableValues[symbol], remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let operand1Evaluation = evaluate(remainingOps)
                if let operand1 = operand1Evaluation.result {
                    let operand2Evaluation = evaluate(operand1Evaluation.remainingOps)
                    if let operand2 = operand2Evaluation.result {
                        return (operation(operand2, operand1), operand2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    // Entry point to evaluate function
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    // Places an operand onto the stack
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    // Places a "variable" operand onto the stack.
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    // Perform an operation (pushes an operation onto the stack)
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    // Reset calculator be freshly initialized
    func clearOperations() {
        opStack.removeAll()
        // Clear history
    }
    
    
}