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
    case getTransaction
    case getAccount
    case getBalance
    case sendExternalMessage
    case runGetMethodFift
    case runGetMethodAbi
    case waitForTransaction
    case getConfigParams
}

class TonJsonRpcController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("jsonRpc", use: jsonRpc)
    }
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: EverRPCMethods = try req.content.decode(EverJsonRPCRequestMethod.self).method
        
        switch method {
        case .getTransactions:
            return try await encodeResponse(for: req, json: try await EverTransactionsController.shared.getTransactions(req))
        case .getTransaction:
            return try await encodeResponse(for: req, json: try await EverTransactionsController.shared.getTransaction(req))
        case .getAccount:
            return try await encodeResponse(for: req, json: try await EverAccountsController.shared.getAccount(req))
        case .getBalance:
            return try await encodeResponse(for: req, json: try await EverAccountsController.shared.getBalance(req))
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
