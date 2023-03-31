//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 05.05.2022.
//

import Foundation
import BigInt
import SwiftRegularExpression
import SwiftExtensionsPack


extension String {
    
    init?(hexadecimal string: String, encoding: String.Encoding = .utf8) {
        guard let data = string.hexadecimalToData else { return nil }
        self.init(data: data, encoding: encoding)
    }

    var hexadecimalToData: Data? {
        Data(hexString: self)
    }

    var toHexadecimal: String {
        let data: Data = .init(self.utf8)
        return data.map { String(format: "%02x", $0) }.joined()
    }

    var toNanoCrystals: BigInt {
        toNanoCrystals(decimals: 9)
    }

    func toNanoCrystals(decimals: Int) -> BigInt {
        let balance: String = self.replace(#","#, ".")

        var result: String = ""
        let match: [Int: String] = balance.regexp(#"(\d+)\.(\d+)"#)
        let isFloat: Bool = match[2] != nil
        if isFloat {
            if
                let integer: String = match[1],
                let float: String = match[2]?.replace(#"0+$"#, "")
            {
                var temp: String = ""
                var counter = decimals
                for char in float {
                    if counter == 0 {
                        temp.append(".")
                    }
                    counter -= 1
                    temp.append(char)
                }
                if counter < 0 { return 0 }
                if counter > 0 {
                    for _ in 0..<counter {
                        temp.append("0")
                    }
                }
                if let int = BigInt(integer), int > 0 {
                    temp = "\(integer)\(temp)"
                }
                result = temp
            }
        } else {
            result.append(balance.replace(#"^0+"#, ""))
            for _ in 0..<decimals {
                result.append("0")
            }
        }

        guard let bigInt = BigInt(result) else { fatalError("toNanoCrystals: Not convert string to BigInt") }
        return bigInt
    }

    func nanoCrystalToCrystal(decimals: Int = 9) -> String {
        guard let bigInt = BigInt(self) else { fatalError("toNanoCrystals: Not convert string to BigInt") }
        return bigInt.nanoCrystalToCrystal(decimals: decimals)
    }

    func crystalToNanoCrystal(decimals: Int = 9) -> String {
        String(self.toNanoCrystals(decimals: decimals))
    }

    func toModel<T: Decodable>(_ type: T.Type) throws -> T {
        guard let data = self.data(using: .utf8) else { throw AppError(reason: "Get data from \(self) - FAIL") }
        let model: T = try JSONDecoder().decode(T.self, from: data)
        return model
    }
    
    func roundPrice(digits: Int = 2, rule: FloatingPointRoundingRule = .down) -> String {
        if digits == 0 { return self.replace(#"(,|\.)\d+"#, "") }
        if Int(self) == 0 { return "0" }
        var price: Double = .init()
        guard let doublePrice = Double(self) else { return self }
        price = doublePrice - Double(Int(doublePrice))
        if price == 0 { return String(Int(Double(self) ?? 0)) }
        var roundNumber: Int = digits
        var number = 0
        while (price - Double(Int(price))) > 0 || String(Int(price)).count <= digits {
            if String(Int(price)).count == digits {
                roundNumber = number
            }
            number += 1
            price *= 10
        }
        return doublePrice.round(toDecimalPlaces: UInt(roundNumber), rule: rule).toString()
    }
}

extension String {
    
    var toDataFromHex: Data? {
        Data(hexString: self.lowercased().hexClear.remove0x.addFirstZeroToHexIfNeeded)
    }
}


extension String {
    /// Encodes or decodes into a base64url safe representation
    func base64ToBase64URL() -> String {
        // Make base64 string safe for passing into URL query params
        let base64url = self.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
        
        return base64url
    }
    
    func base64URLToBase64() -> String {
        // Return to base64 encoding
        var base64 = self.replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")
        // Add any necessary padding with `=`
        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        
        return base64
    }
    
    func base64ToByteArray() -> Array<UInt8> {
        Array<UInt8>(Data(base64Encoded: self.base64URLToBase64())!)
    }
}


extension String {
    var everAddrLowercased: String { self.contains(":") ? self.lowercased() : self }
}
