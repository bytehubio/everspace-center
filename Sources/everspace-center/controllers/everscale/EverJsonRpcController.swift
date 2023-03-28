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
    case sendAndWaitTransaction
    case getLastMasterBlock
    case getBlock
    case getRawBlock
}

class EverJsonRpcController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("jsonRpc", use: jsonRpc)
    }
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: EverRPCMethods = try req.content.decode(EverJsonRPCRequestMethod.self).method
        
        switch method {
        case .getTransactions:
            return try await encodeResponse(for: req, json: try await everTransactionsController.getTransactions(req))
        case .getTransaction:
            return try await encodeResponse(for: req, json: try await everTransactionsController.getTransaction(req))
        case .getAccount:
            return try await encodeResponse(for: req, json: try await everAccountsController.getAccount(req))
        case .getBalance:
            return try await encodeResponse(for: req, json: try await everAccountsController.getBalance(req))
        case .sendExternalMessage:
            return try await encodeResponse(for: req, json: try await everSendController.sendExternalMessage(req))
        case .runGetMethodAbi:
            return try await encodeResponse(for: req, json: try await everRunGetMethodsController.runGetMethodAbi(req))
        case .runGetMethodFift:
            return try await encodeResponse(for: req, json: try await everRunGetMethodsController.runGetMethodFift(req))
        case .waitForTransaction:
            return try await encodeResponse(for: req, json: try await everSendController.waitForTransaction(req))
        case .getConfigParams:
            return try await encodeResponse(for: req, json: try await everBlocksController.getConfigParams(req))
        case .sendAndWaitTransaction:
            return try await encodeResponse(for: req, json: try await everSendController.sendAndWaitTransaction(req))
        case .getLastMasterBlock:
            return try await encodeResponse(for: req, json: try await everBlocksController.getLastMasterBlock(req))
        case .getBlock:
            return try await encodeResponse(for: req, json: try await everBlocksController.getBlock(req))
        case .getRawBlock:
            return try await encodeResponse(for: req, json: try await everBlocksController.getRawBlock(req))
        }
    }
}

