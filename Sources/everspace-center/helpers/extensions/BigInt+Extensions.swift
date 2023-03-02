//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 05.05.2022.
//

import Foundation
import BigInt

extension BigInt {

    var nanoCrystalToCrystal: String {
        nanoCrystalToCrystal(decimals: 9)
    }

    func nanoCrystalToCrystal(decimals: Int) -> String {
        let balanceCount = String(self).count
        let different = balanceCount - decimals
        var floatString = ""
        if different <= 0 {
            floatString = "0."
            for _ in 0..<different * -1 {
                floatString.append("0")
            }
            floatString.append(String(self))
        } else {
            var counter = different
            for char in String(self) {
                if counter == 0 {
                    floatString.append(".")
                }
                floatString.append(char)
                counter -= 1
            }
        }

        return floatString.replace(#"(\.|)0+$"#, "")
    }
}
