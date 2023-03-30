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
    case sendAndWaitTransaction
    case getLastMasterBlock
    case getBlock
    case getRawBlock
    case lookupBlock
}

class TonJsonRpcController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("jsonRpc", use: jsonRpc)
    }
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: TonRPCMethods = try req.content.decode(TonJsonRPCRequestMethod.self).method
        
        switch method {
        case .getTransactions:
            return try await encodeResponse(for: req, json: try await tonTransactionsController.getTransactions(req))
        case .getTransaction:
            return try await encodeResponse(for: req, json: try await tonTransactionsController.getTransaction(req))
        case .getAccount:
            return try await tonAccountsController.getAccount(req)
        case .getBalance:
            return try await tonAccountsController.getBalance(req)
        case .sendExternalMessage:
            return try await encodeResponse(for: req, json: try await tonSendController.sendExternalMessage(req))
        case .runGetMethodAbi:
            return try await encodeResponse(for: req, json: try await tonRunGetMethodsController.runGetMethodAbi(req))
        case .runGetMethodFift:
            return try await encodeResponse(for: req, json: try await tonRunGetMethodsController.runGetMethodFift(req))
        case .waitForTransaction:
            return try await encodeResponse(for: req, json: try await tonSendController.waitForTransaction(req))
        case .getConfigParams:
            return try await encodeResponse(for: req, json: try await tonBlocksController.getConfigParams(req))
        case .sendAndWaitTransaction:
            return try await encodeResponse(for: req, json: try await tonSendController.sendAndWaitTransaction(req))
        case .getLastMasterBlock:
            return try await encodeResponse(for: req, json: try await tonBlocksController.getLastMasterBlock(req))
        case .getBlock:
            return try await encodeResponse(for: req, json: try await tonBlocksController.getBlock(req))
        case .getRawBlock:
            return try await encodeResponse(for: req, json: try await tonBlocksController.getRawBlock(req))
        case .lookupBlock:
            return try await encodeResponse(for: req, json: try await tonBlocksController.lookupBlock(req))
        }
    }
}
