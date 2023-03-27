//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 27.03.2023.
//

import Foundation
import SwiftExtensionsPack
import EverscaleClientSwift
import Vapor

public enum TonRPCMethods: String, Content {
    case getTransactions
    case getAccount
    case getBalance
}

class TonJsonRpcController {
    
    static let transactionsController: EverTransactionsController = .init()
    static let accountsController: EverAccountsController = .init()
    
    init() {
        Self.transactionsController.prepareSwagger(SwaggerController.openAPIBuilder)
        Self.accountsController.prepareSwagger(SwaggerController.openAPIBuilder)
    }
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: TonRPCMethods = try req.content.decode(TonJsonRPCRequestMethod.self).method
        
        switch method {
        case .getTransactions:
            return try await encodeResponse(for: req, json: try await Self.transactionsController.getTransactionsRpc(req))
        case .getAccount:
            return try await encodeResponse(for: req, json: try await Self.accountsController.getAccountRpc(req))
        case .getBalance:
            return try await encodeResponse(for: req, json: try await Self.accountsController.getBalanceRpc(req))
        }
    }
}

extension TonJsonRpcController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("", use: jsonRpc)
    }
    
    public func encodeResponse(for request: Vapor.Request, json: String) async throws -> Vapor.Response {
        let res = Response()
        res.headers.add(name: "Content-Type", value: "application/json")
        res.body = Response.Body(string: json)
        return res
    }
}
