//
//  VectorSet.swift
//  simplex
//
//  Created by Михаил on 30.11.15.
//  Copyright © 2015 Михаил. All rights reserved.
//

import UIKit

enum SearchParameter : Int {
    case min, max
    
    func description() -> String {
        switch self {
        case .min:
            return "minimum"
        case .max:
            return "maximum"
        }
    }
}

class VectorSet: NSObject {
    var vectors: [Vector] = [Vector]()
    
    init(set: SetOfEquations) {
        super.init()
        
        //Количество строк равно количеству уравнений
        let rows: Int = set.equations.count
        //Количество колонок равно количеству операндов в уравнении
        let columns: Int = (set.equations.first?.operands.count)!
        
        //Устанавливаем вектора
        //Индекс вектора с решениями равен 0 по умолчанию
        let solutionVector = Vector()
        for equation in set.equations {
            solutionVector.addCoefficient(equation.solution)
        }
        addVector(solutionVector)
        
        for column in 0..<columns {
            let vector = Vector()
            for row in 0..<rows {
                vector.addCoefficient(set.equations[row].operands[column].coefficient)
            }
            vector.index = (set.equations.last?.operands[column].index)!
            addVector(vector)
        }
    }
    
    func addVector(vector: Vector) {
        self.vectors.append(vector)
    }
    
    func getVectorByIndex(index: Int) -> Vector? {
        for vector in vectors {
            if vector.index == index {
                return vector
            }
        }
        return nil
    }
    
    func getBasisVectors() -> [Vector] {
        //Количество базисных векторов равно количеству уравнений в системе
        let basisCount: Int = (vectors.first?.coefficients.count)!
        var basisVectors: [Vector] = [Vector]();
        
        for i in 0..<basisCount {
            for vector in vectors {
                //Проверяем, является ли вектор базисным
                var isBasis = true
                for (index, coefficient) in vector.coefficients.enumerate() {
                    if (index == i && coefficient != 1) || (index != i && coefficient != 0) {
                        isBasis = false;
                    }
                }
                //Если вектор является базисным, то добавляем его в массив
                //и ищем следующий базисный вектор
                if isBasis {
                    basisVectors.append(vector)
                    continue
                }
            }
        }
        return basisVectors
    }
    
    func getNotBasisVectors() -> [Vector] {
        var notBasisVectors: [Vector] = [Vector]()
        let basisVectors = getBasisVectors()
        
        var basisIndexes: [Int] = [Int]()
        for index in 0..<basisVectors.count {
            let basisIndex = basisVectors[index].index
            basisIndexes.append(basisIndex)
        }
        
        for vector in vectors {
            if !basisIndexes.contains(vector.index) {
                notBasisVectors.append(vector)
            }
        }
        
        return notBasisVectors
    }
    
    func getBasisVectorsIndices() -> [Int] {
        let basisVectors = getBasisVectors()
        var basisIndices = [Int]()
        
        //Генерируем массив с индексами не базисных векторов
        for basis in basisVectors {
            basisIndices.append(basis.index)
        }
        
        return basisIndices
    }
    
    func getNotBasisVectorsIndices() -> [Int] {
        let notBasisVectors = getNotBasisVectors()
        var notBasisIndices = [Int]()
        
        //Генерируем массив с индексами не базисных векторов
        for notBasis in notBasisVectors {
            notBasisIndices.append(notBasis.index)
        }
        
        return notBasisIndices
    }
    
    func decomposeVectorByBasis(index: Int) -> [Double]? {
        let basisIndices = getBasisVectorsIndices()
        
        //Проверяем не является ли вектор одним из базисных
        if basisIndices.contains(index) {
            return nil
        }
        
        if let vector = getVectorByIndex(index) {
            var decomposition: [Double] = [0]//[Double]()
            
            //Заполняем массив 0
            for i in 1..<vectors.count {
                decomposition.insert(0, atIndex: i)
            }
            
            //Расставляем необходимые коэффициенты в соответсвии с заданным вектором
            for i in 0..<basisIndices.count {
                decomposition[basisIndices[i]] = vector.coefficients[i]
            }
            //Удаляем первый элемент, который относится к 0-ому вектору
            decomposition.removeFirst()
            
            return decomposition
        }
        
        return nil
    }
    
    func getInitialPlan() -> Plan {
        if let values = decomposeVectorByBasis(0) {
            return Plan(values: values)
        } else {
            return Plan(values: [])
        }
    }
    
    func getMarks(function: Function) -> [Double] {
        var marks = [Double]()
        //Получаем массив с базисными векторами
        let basisVectors = self.getBasisVectors()
        
        //Считаем оценку каждого вектора
        for vector in self.vectors {
            //Считаем Z (Сумму произведений C-базисного вектора на коэффициент вектора)
            var z: Double = 0
            for index in 0..<vector.coefficients.count {
                let basisVector = basisVectors[index]
                let cBasis = function.getOperandByIndex(basisVector.index).coefficient
                
                let coefficient = vector.coefficients[index]
                
                z += cBasis * coefficient
            }
            let mark = z - function.getOperandByIndex(vector.index).coefficient
            marks.insert(mark, atIndex: vector.index)
        }
        
        return marks
    }
    
    func isOptimal(marks: [Double], parameter: SearchParameter) -> Int? {
        var badVectorIndex: Int?
        
        for index in 0..<marks.count {
            let mark = marks[index]
            switch parameter {
            case .min where mark > 0, .max where mark < 0:
                badVectorIndex = index
                break
            default:
                continue
            }
        }
        
        return badVectorIndex
    }
    
    func findNewPlan(inputVectorIndex: Int) -> Plan {
        let plan = getInitialPlan()
        let decomposition = decomposeVectorByBasis(inputVectorIndex)!
        
        //Находим минимальное значение Theta
        let minTheta = findVectorForOuputFromBasis(inputVectorIndex)
        let minThetaValue = minTheta["value"]!
        
        //Генерируем новый план
        var newPlan = [Double]()
        for i in 0..<plan.values.count {
            let value = Double(plan.values[i] - decomposition[i] * minThetaValue)
            newPlan.append(value)
        }
        newPlan[inputVectorIndex - 1] = minThetaValue
        
        return Plan(values: newPlan)
    }
    
    func replaceVectorsInBasis(inputVector: Vector, outputVector: Vector) {
        //Находим необходимый индекс коэффициента 1
        //в векторе для вывода из базиса
        var oneCoefficientIndex: Int?
        for (i, coefficient) in outputVector.coefficients.enumerate() {
            if coefficient == 1 {
                oneCoefficientIndex = i
            }
        }
        
        if let coefficientIndex = oneCoefficientIndex {
            let coefficientOppositeOfOne = inputVector.coefficients[coefficientIndex]
            if  coefficientOppositeOfOne != 1 {
                //Делим coefficientIndex-коэффициент всех векторов на coefficientOppositeOfOne
                for vector in self.vectors {
                    vector.coefficients[coefficientIndex] /= coefficientOppositeOfOne
                }
            }
            
            var inputConversationCoefficients = [Double]()
            for coefficient in inputVector.coefficients {
                //m + k*n = 0;
                //k = - m/n
                let m = coefficient
                let n = inputVector.coefficients[coefficientIndex]
                let k = -m / n
                inputConversationCoefficients.append(k)
            }
            
            //Вводим/Выводим вектора
            for vector in self.vectors {
                for i in 0..<vector.coefficients.count {
                    //Если встречаем коэфициент с тем же индексом, что и oneCoefficientIndex
                    //(коэфф. находитс в той же строке)
                    if i == coefficientIndex {
                        continue
                    }
                    
                    vector.coefficients[i] = vector.coefficients[i] + vector.coefficients[coefficientIndex] * inputConversationCoefficients[i]
                }
            }
        }
    }
    
    func findVectorForOuputFromBasis(index: Int) -> [String : Double] {
        let plan = getInitialPlan()
        let decomposition = decomposeVectorByBasis(index)!
        
        //Находим минимальное значение Theta
        var minTheta: [String: Double] = [String: Double]()
        minTheta["value"] = Double(Int.max)
        minTheta["index"] = -1
        
        for i in 0..<plan.values.count {
            let theta = Double(plan.values[i] / decomposition[i])
            if theta > 0 && theta < minTheta["value"] {
                minTheta["value"] = theta
                minTheta["index"] = Double(i + 1)
            }
        }
        
        return minTheta
    }
    
    func findOptimalPlan(function: Function, searchParameter: SearchParameter) -> Plan {
        var optimalPlan = getInitialPlan()
        var marks = getMarks(function)
        //Добавляем изначальный план для последующего вывода пользователю
        OutputGenerator.appendPlan(optimalPlan, marks: marks)
        
        while let badVectorIndex = isOptimal(getMarks(function), parameter: searchParameter) {
            //Находим индекс минимального значения Theta -
            //индекс вектора для вывода из базиса
            let minThetaIndex = Int(findVectorForOuputFromBasis(badVectorIndex)["index"]!)
            
            //Генерируем новый план
            optimalPlan = findNewPlan(badVectorIndex)
            
            //Вводим в базис вектор с индексом badVectorIndex
            //и выводим вектор с индексом minThetaIndex
            if let inputVector = getVectorByIndex(badVectorIndex), let outputVector = getVectorByIndex(minThetaIndex) {
                replaceVectorsInBasis(inputVector, outputVector: outputVector)
            } else {
                break
            }
            
            marks = getMarks(function)
            //Добавляем новый план для последующего вывода пользователю
            OutputGenerator.appendPlan(optimalPlan, marks: marks)
        }
        
        return optimalPlan
    }
    
    func getVectorsDescription() -> String {
        var description: String = ""
        
        for vector in vectors {
            description += vector.getDescription() + "\n"
        }

        return description
    }
}
