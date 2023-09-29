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

extension Int {
    
    func convert(radix: Int, bigEndian: Bool = true) -> String {
        let alphabet: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
        if radix > alphabet.count { fatalError("radix: \(radix) is not supported") }
        var result: String = .init()
        var number = self
        while number > 0 {
            let digit = number % radix
            number = number / radix
            if bigEndian {
                result = alphabet[digit] + result
            } else {
                result += alphabet[digit]
            }
        }
        if result.count % 2 != 0 {
            result = "0" + result
        }
        
        return result.isEmpty ? "00" : result
    }
}

extension BigInt {
    
    func convert(radix: Int, bigEndian: Bool = true) -> String {
        BigUInt(self).convert(radix: radix, bigEndian: bigEndian)
    }
}

extension BigUInt {
    
    func convert(radix: Int, bigEndian: Bool = true) -> String {
        if self == 0 { return "0" }
        let alphabet: [String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
        if radix > alphabet.count { fatalError("radix: \(radix) is not supported") }
        let radix: BigUInt = BigUInt(radix)
        var result: String = .init()
        var number = self
        while number > 0 {
            let digit: Int = Int(number % radix)
            number = number / radix
            if bigEndian {
                result = alphabet[digit] + result
            } else {
                result += alphabet[digit]
            }
        }
        /// this nedeed only for initializator Data(stringHex: hex)
//        if result.count % 2 != 0 {
//            result = "0" + result
//        }
        
        return result
    }
    
    var toHex: String { self.convert(radix: 16) }
}

extension String {
    var addHexZeroX: String {
        if !self[#"^0x"#] {
            return "0x\(self)"
        }
        return self
    }
    var removeHexZeroX: String { self.replace(#"^0x"#, "") }
    var deleteHexZeroX: String { self.removeHexZeroX }
    var add0x: String { addHexZeroX }
    var remove0x: String { self.removeHexZeroX }
    var delete0x: String { self.removeHexZeroX }
    
    /// this nedeed only for initializator Data(stringHex: hex)
    var addFirstZeroToHexIfNeeded: String {
        var result: String = self
        if !result[#"^0x"#], result.count % 2 != 0 {
            result = "0" + result
        }
        
        return result
    }
}

extension String {
    var toHexFromStringDecimal: String? {
        guard let bigUInt = BigUInt(self) else { return nil }
        return bigUInt.convert(radix: 16)
    }
    
    func toHexFromStringDecimal(_ decimals: Int) -> String? {
        crystalToNanoCrystal(decimals: decimals).toHexFromStringDecimal
    }
    
    func toStringDecimalFromHex() throws -> String {
        guard let bigUInt = BigUInt(self.remove0x, radix: 16) else { throw AppError("toStringDecimalFromHex: dont convert \(self)") }
        return String(bigUInt)
    }
    
    func toDecimalFromHex() -> BigInt? {
        BigInt(self.remove0x, radix: 16)
    }
    
    var hexClear: String {
        self.replace(#"^0x0+"#, "0x")
    }
    
    func toBigInt() throws -> BigInt {
        guard let number = BigInt(self.hexClear.remove0x) else { throw AppError("\(self) not converted to BigInt") }
        return number
    }
}

extension BigInt {
    var toHex: String { self.convert(radix: 16) }
}

extension Int {
    var toHex: String { self.convert(radix: 16) }
}

