//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.03.2023.
//

import Foundation
import EverscaleClientSwift
import SwiftExtensionsPack

extension AnyValue {

    func toModel<T: Decodable>(_ type: T.Type) throws -> T {
        if let json = self.toJson() {
            return try json.toModel(type.self)
        } else {
            throw makeError(AppError(reason: "Not convert AnyValue to json."))
        }
    }
}

