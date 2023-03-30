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

public enum RfldRPCMethods: String, Content {
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

class RfldJsonRpcController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("jsonRpc", use: jsonRpc)
    }
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: RfldRPCMethods = try req.content.decode(JsonRPCRequestMethod<RfldRPCMethods>.self).method
        
        switch method {
        case .getTransactions:
            return try await rfldTransactionsController.getTransactions(req)
        case .getTransaction:
            return try await rfldTransactionsController.getTransaction(req)
        case .getAccount:
            return try await rfldAccountsController.getAccount(req)
        case .getBalance:
            return try await rfldAccountsController.getBalance(req)
        case .sendExternalMessage:
            return try await rfldSendController.sendExternalMessage(req)
        case .runGetMethodAbi:
            return try await rfldRunGetMethodsController.runGetMethodAbi(req)
        case .runGetMethodFift:
            return try await rfldRunGetMethodsController.runGetMethodFift(req)
        case .waitForTransaction:
            return try await rfldSendController.waitForTransaction(req)
        case .getConfigParams:
            return try await rfldBlocksController.getConfigParams(req)
        case .sendAndWaitTransaction:
            return try await rfldSendController.sendAndWaitTransaction(req)
        case .getLastMasterBlock:
            return try await rfldBlocksController.getLastMasterBlock(req)
        case .getBlock:
            return try await rfldBlocksController.getBlock(req)
        case .getRawBlock:
            return try await rfldBlocksController.getRawBlock(req)
        case .lookupBlock:
            return try await rfldBlocksController.lookupBlock(req)
        case .getBlockByTime:
            return try await rfldBlocksController.getBlockByTime(req)
        case .estimateFee:
            return try await rfldSendController.estimateFee(req)
        case .getBlocksTransactions:
            return try await rfldTransactionsController.getBlocksTransactions(req)
        }
    }
}
