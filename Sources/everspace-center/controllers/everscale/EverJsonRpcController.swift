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
import Swiftgger

public enum EverRPCMethods: String, Content {
    case getTransactions
    case getTransaction
    case getAccount
    case getBalance
    case sendExternalMessage
    case runGetMethodFift
    case runGetMethodAbi
    case waitForTransaction
    case getConfigParams
}

class EverJsonRpcController {
    
    static let shared: EverJsonRpcController = .init()
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: EverRPCMethods = try req.content.decode(EverJsonRPCRequestMethod.self).method
        
        switch method {
        case .getTransactions:
            return try await encodeResponse(for: req, json: try await EverTransactionsController.shared.getTransactionsRpc(req))
        case .getTransaction:
            return try await encodeResponse(for: req, json: try await EverTransactionsController.shared.getTransactionRpc(req))
        case .getAccount:
            return try await encodeResponse(for: req, json: try await EverAccountsController.shared.getAccountRpc(req))
        case .getBalance:
            return try await encodeResponse(for: req, json: try await EverAccountsController.shared.getBalanceRpc(req))
        case .sendExternalMessage:
            return try await encodeResponse(for: req, json: try await EverSendController.shared.sendExternalMessage(req))
        case .runGetMethodAbi:
            return try await encodeResponse(for: req, json: try await EverRunGetMethodsController.shared.runGetMethodAbi(req))
        case .runGetMethodFift:
            return try await encodeResponse(for: req, json: try await EverRunGetMethodsController.shared.runGetMethodFift(req))
        case .waitForTransaction:
            return try await encodeResponse(for: req, json: try await EverSendController.shared.waitForTransaction(req))
        case .getConfigParams:
            return try await encodeResponse(for: req, json: try await EverBlocksController.shared.getConfigParams(req))
        }
    }
}

extension EverJsonRpcController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("jsonRpc", use: jsonRpc)
    }
    
    public func encodeResponse(for request: Vapor.Request, json: String) async throws -> Vapor.Response {
        let res = Response()
        res.headers.add(name: "Content-Type", value: "application/json")
        res.body = Response.Body(string: json)
        return res
    }
}

