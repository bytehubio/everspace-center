//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 28.03.2023.
//

import Foundation
import SwiftExtensionsPack
import EverscaleClientSwift
import Vapor

public enum EverDevRPCMethods: String, Content {
    case getTransactions
    case getTransaction
    case getAccount
    case getBalance
    case sendExternalMessage
    case runGetMethodFift
    case runGetMethodAbi
    case waitForTransaction
    case getConfigParams
    case sendAndWaitTransaction
}

class EverDevnetJsonRpcController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("jsonRpc", use: jsonRpc)
    }
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: EverRPCMethods = try req.content.decode(EverJsonRPCRequestMethod.self).method
        
        switch method {
        case .getTransactions:
            return try await encodeResponse(for: req, json: try await everDevnetTransactionsController.getTransactions(req))
        case .getTransaction:
            return try await encodeResponse(for: req, json: try await everDevnetTransactionsController.getTransaction(req))
        case .getAccount:
            return try await encodeResponse(for: req, json: try await everDevnetAccountsController.getAccount(req))
        case .getBalance:
            return try await encodeResponse(for: req, json: try await everDevnetAccountsController.getBalance(req))
        case .sendExternalMessage:
            return try await encodeResponse(for: req, json: try await everDevnetSendController.sendExternalMessage(req))
        case .runGetMethodAbi:
            return try await encodeResponse(for: req, json: try await everDevnetRunGetMethodsController.runGetMethodAbi(req))
        case .runGetMethodFift:
            return try await encodeResponse(for: req, json: try await everDevnetRunGetMethodsController.runGetMethodFift(req))
        case .waitForTransaction:
            return try await encodeResponse(for: req, json: try await everDevnetSendController.waitForTransaction(req))
        case .getConfigParams:
            return try await encodeResponse(for: req, json: try await everDevnetBlocksController.getConfigParams(req))
        case .sendAndWaitTransaction:
            return try await encodeResponse(for: req, json: try await everDevnetSendController.sendAndWaitTransaction(req))
        }
    }
}
