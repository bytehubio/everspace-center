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

public enum EverDevnetRPCMethods: String, Content {
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
}

class EverDevnetJsonRpcController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("jsonRpc", use: jsonRpc)
    }
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: EverDevnetRPCMethods = try req.content.decode(JsonRPCRequestMethod<EverDevnetRPCMethods>.self).method
        
        switch method {
        case .getTransactions:
            return try await everDevnetTransactionsController.getTransactions(req)
        case .getTransaction:
            return try await everDevnetTransactionsController.getTransaction(req)
        case .getAccount:
            return try await everDevnetAccountsController.getAccount(req)
        case .getBalance:
            return try await everDevnetAccountsController.getBalance(req)
        case .sendExternalMessage:
            return try await everDevnetSendController.sendExternalMessage(req)
        case .runGetMethodAbi:
            return try await everDevnetRunGetMethodsController.runGetMethodAbi(req)
        case .runGetMethodFift:
            return try await everDevnetRunGetMethodsController.runGetMethodFift(req)
        case .waitForTransaction:
            return try await everDevnetSendController.waitForTransaction(req)
        case .getConfigParams:
            return try await everDevnetBlocksController.getConfigParams(req)
        case .sendAndWaitTransaction:
            return try await everDevnetSendController.sendAndWaitTransaction(req)
        case .getLastMasterBlock:
            return try await everDevnetBlocksController.getLastMasterBlock(req)
        case .getBlock:
            return try await everDevnetBlocksController.getBlock(req)
        case .getRawBlock:
            return try await everDevnetBlocksController.getRawBlock(req)
        case .lookupBlock:
            return try await everDevnetBlocksController.lookupBlock(req)
        case .getBlockByTime:
            return try await everDevnetBlocksController.getBlockByTime(req)
        case .estimateFee:
            return try await everDevnetSendController.estimateFee(req)
        }
    }
}
