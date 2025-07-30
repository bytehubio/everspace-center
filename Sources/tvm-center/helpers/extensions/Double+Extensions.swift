//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 05.05.2022.
//

import Foundation

extension Double {
    public func round(toDecimalPlaces places: Int) -> Double
    {
        let divisor = Double.pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
