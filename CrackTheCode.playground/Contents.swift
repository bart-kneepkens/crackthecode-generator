import Cocoa

struct Statement: CustomStringConvertible, Hashable {
    let left: Lock
    let right: Lock
    let result: Int
    
    var description: String {
        return "\(left)+\(right)=\(result)"
    }
}

enum Lock: String {
    case A
    case B
    case C
    case D
    case E
    case F
}

let ALL_LOCKS: [Lock] = [.A, .B, .C, .D, .E, .F]

func solve(statements: Set<Statement>, possibilities: Int) -> [Lock: Set<Int>]?{
    let possibleValues = Set(0..<possibilities)
    var possibleAnswers: [Lock: Set<Int>] = [:]
    
    for lock in ALL_LOCKS.prefix(upTo: possibilities - 1) {
        possibleAnswers[lock] = possibleValues
    }
    
    var isDone = false
    
    while !isDone {
        let initialPossible = possibleAnswers
        
        for statement in statements {
            //            print(statement)
            var newRight: Set<Int> =  []
            var newLeft: Set<Int> = []
            
            for num in possibleAnswers[statement.left]! {
                let rightNums = possibleAnswers[statement.right]!.filter({ num + $0 == statement.result })
                if rightNums.count > 0 {
                    rightNums.forEach({ newRight.insert($0) })
                }
            }
            
            for num in possibleAnswers[statement.right]! {
                let leftNums = possibleAnswers[statement.left]!.filter({ num + $0 == statement.result })
                if leftNums.count > 0 {
                    leftNums.forEach({ newLeft.insert($0) })
                }
            }
            
            possibleAnswers[statement.right]! = possibleAnswers[statement.right]!.intersection(newRight)
            possibleAnswers[statement.left]! = possibleAnswers[statement.left]!.intersection(newLeft)
        }
        
        // Nothing changed this time around, meaning there are multiple answers.
        if initialPossible == possibleAnswers {
            return nil
        }
        
        var kut = true
        for answer in possibleAnswers {
            if answer.value.count > 1 {
                kut = false
            }
        }
        
        
        isDone = kut
    }
    
    return possibleAnswers
}

//if let solution = solve(statements: [
//    Statement(left: .A, right: .B, result: 5),
//    Statement(left: .B, right: .C, result: 4),
//    Statement(left: .A, right: .C, result: 4),
//], possibilities: 4) {
//    print("A:\(solution[Lock.A]!.first!) B:\(solution[Lock.B]!.first!) C:\(solution[Lock.C]!.first!)");
//} else {
//    print("Failed. bye")
//}

//let randomSequence: [Lock : Int] = [.A: 3, .B: 2, .C: 1]

//let maxValue = 6 // 3 + 3
//let possibilities = 4 // 0, 1, 2, 3'

//var workingStatementsFound = false

func generateRandomStatements(for sequence: [Lock: Int]) -> Set<Statement> {
    var generatedStatements = Set<Statement>()
    let possibleLocks: Set<Lock> = Set(ALL_LOCKS.prefix(upTo: sequence.count))
    
    while(generatedStatements.count < sequence.count) {
        
        let left = possibleLocks.randomElement()
        let right = possibleLocks.filter({ $0 != left }).randomElement()
        let result = sequence[left!]! + sequence[right!]!
        
        let newStatement = Statement(left: left!, right: right!, result: result)
        
        if generatedStatements.contains(where: { st -> Bool in
            if st.result == newStatement.result {
                if st.left == newStatement.left && st.right == newStatement.right {
                    return true
                } else if st.left == newStatement.right && st.right == newStatement.left {
                    return true
                }
            }
            return false
        }) {
            continue
        } else {
            generatedStatements.insert(newStatement)
        }
    }
    
    return generatedStatements
}



//print(generateRandomStatements(for: [.A: 1, .B: 2, .C: 3, .D: 4, .E: 5, .F: 6]))

func generateRandomSequence(withLength length: Int) -> [Lock: Int] {
    let locks: [Lock] = Array(ALL_LOCKS.prefix(upTo: length))
    let maxValue = length
    var sequence: [Lock: Int] = [:]
    
    for lock in locks {
        let randomValue = Array(0...maxValue).randomElement() ?? -1
        sequence[lock] = randomValue
    }
    
    return sequence
}


var hits = 0

while hits < 15 {
    let randomSequence = generateRandomSequence(withLength: 6)
//    let randomSequence: [Lock: Int] = [.A: 2, .B: 2, .C: 2, .D: 3, .E: 4, .F: 1]
    
//    print(randomSequence)
    
    var solutionFound = false
    
//    while !solutionFound {
        let randomStatements = generateRandomStatements(for: randomSequence)
        if let solved = solve(statements: randomStatements, possibilities: 7) {
            solutionFound = true
            
            let sequenceValueStrings = randomSequence.map { key, value -> String in
                return "\(key.rawValue):\(value)"
            }
            
            print("statements \(randomStatements) solve sequence \(sequenceValueStrings)")
            hits += 1
        }
//        else {
//            print("not working, \(randomStatements)")
//        }
//    }
}

print("done")
