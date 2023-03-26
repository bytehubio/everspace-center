//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 23.03.2023.
//

import Foundation
import SwiftExtensionsPack
import EverscaleClientSwift
import Vapor

public enum RPCMethods: String, Content {
    case everscale_getTransactions
    case everscale_getAccount
    case everscale_getBalance
}

class JsonRpcController {
    
    static let transactionsController: TransactionsController = .init()
    static let accountsController: AccountsController = .init()
    
    init() {
        Self.transactionsController.prepareSwagger(SwaggerController.openAPIBuilder)
        Self.accountsController.prepareSwagger(SwaggerController.openAPIBuilder)
    }
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: RPCMethods = try req.content.decode(JsonRPCRequestMethod.self).method
        
        switch method {
        case .everscale_getTransactions:
            return try await encodeResponse(for: req, json: try await Self.transactionsController.getTransactionsRpc(req))
        case .everscale_getAccount:
            return try await encodeResponse(for: req, json: try await Self.accountsController.getAccountRpc(req))
        case .everscale_getBalance:
            return try await encodeResponse(for: req, json: try await Self.accountsController.getBalanceRpc(req))
        }
    }
}

extension JsonRpcController: RouteCollection {
    
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

