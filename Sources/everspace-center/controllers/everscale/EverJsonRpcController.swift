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
    case lookupBlock
    case getBlockByTime
    case estimateFee
    case getBlocksTransactions
}

class EverJsonRpcController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("jsonRpc", use: jsonRpc)
    }
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: EverRPCMethods = try req.content.decode(JsonRPCRequestMethod<EverRPCMethods>.self).method
        
        switch method {
        case .getTransactions:
            return try await everTransactionsController.getTransactions(req)
        case .getTransaction:
            return try await everTransactionsController.getTransaction(req)
        case .getAccount:
            return try await everAccountsController.getAccount(req)
        case .getBalance:
            return try await everAccountsController.getBalance(req)
        case .sendExternalMessage:
            return try await everSendController.sendExternalMessage(req)
        case .runGetMethodAbi:
            return try await everRunGetMethodsController.runGetMethodAbi(req)
        case .runGetMethodFift:
            return try await everRunGetMethodsController.runGetMethodFift(req)
        case .waitForTransaction:
            return try await everSendController.waitForTransaction(req)
        case .getConfigParams:
            return try await everBlocksController.getConfigParams(req)
        case .sendAndWaitTransaction:
            return try await everSendController.sendAndWaitTransaction(req)
        case .getLastMasterBlock:
            return try await everBlocksController.getLastMasterBlock(req)
        case .getBlock:
            return try await everBlocksController.getBlock(req)
        case .getRawBlock:
            return try await everBlocksController.getRawBlock(req)
        case .lookupBlock:
            return try await everBlocksController.lookupBlock(req)
        case .getBlockByTime:
            return try await everBlocksController.getBlockByTime(req)
        case .estimateFee:
            return try await everSendController.estimateFee(req)
        case .getBlocksTransactions:
            return try await everTransactionsController.getBlocksTransactions(req)
        }
    }
}

