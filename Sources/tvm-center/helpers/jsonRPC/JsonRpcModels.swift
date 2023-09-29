//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 22.03.2023.
//

import Foundation
import SwiftExtensionsPack
import Vapor
import IkigaJSON
import Swiftgger

extension AnyValue: Content {}

public enum RPCVersion: String, Content {
    case v2_0 = "2.0"
}

public struct JsonRPCRequestMethod<T: Content>: Content {
    var method: T
}

public struct JsonRPCRequestDefault: Content {
    var id: String
    var jsonrpc: RPCVersion
}

public struct JsonRPCVoid: Content {}

public struct JsonRPCRequest<M: Content, P: Content>: Content {
    var id: String = "1"
    var jsonrpc: RPCVersion = .v2_0
    var method: M
    var params: P
}

public struct JsonRPCResponse<T: Codable>: Codable {
    
    var id: String
    var jsonrpc: RPCVersion
    var result: T? = nil
    var error: String? = nil
    
    public init(id: String = "1", jsonrpc: RPCVersion = .v2_0, result: T? = nil, error: String? = nil) {
        self.id = id
        self.jsonrpc = jsonrpc
        self.result = result
        self.error = error
    }
    
    public init(result: T) {
        self.id = "1"
        self.jsonrpc = .v2_0
        self.result = result
    }
    
    public init(error: String) {
        self.id = "1"
        self.jsonrpc = .v2_0
        self.error = error
    }
}

public extension Encodable {
    
    func toJson() throws -> String {
        let encoder = IkigaJSONEncoder()
        let jsonData = try encoder.encode(self)
        guard let json = String(data: jsonData, encoding: .utf8) else {
            throw makeError(AppError.mess("Convert json data to string failed"))
        }
        return json
    }
    
    func anyValue() throws -> AnyValue {
        guard let result = try self.toJson().toAnyValue() else {
            throw makeError(AppError("Convert to AnyValue failed"))
        }
        return result
    }
}


