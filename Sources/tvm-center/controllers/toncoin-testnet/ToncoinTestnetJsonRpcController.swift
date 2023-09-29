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

public enum ToncoinTestnetRPCMethods: String, Content {
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
    case getJettonInfo
    case convertAddress
}

class ToncoinTestnetJsonRpcController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("jsonRpc", use: jsonRpc)
    }
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: ToncoinTestnetRPCMethods = try req.content.decode(JsonRPCRequestMethod<ToncoinTestnetRPCMethods>.self).method
        
        switch method {
        case .getTransactions:
            return try await tonTestnetTransactionsController.getTransactions(req)
        case .getTransaction:
            return try await tonTestnetTransactionsController.getTransaction(req)
        case .getAccount:
            return try await tonTestnetAccountsController.getAccount(req)
        case .getBalance:
            return try await tonTestnetAccountsController.getBalance(req)
        case .sendExternalMessage:
            return try await tonTestnetSendController.sendExternalMessage(req)
        case .runGetMethodAbi:
            return try await tonTestnetRunGetMethodsController.runGetMethodAbi(req)
        case .runGetMethodFift:
            return try await tonTestnetRunGetMethodsController.runGetMethodFift(req)
        case .waitForTransaction:
            return try await tonTestnetSendController.waitForTransaction(req)
        case .getConfigParams:
            return try await tonTestnetBlocksController.getConfigParams(req)
        case .sendAndWaitTransaction:
            return try await tonTestnetSendController.sendAndWaitTransaction(req)
        case .getLastMasterBlock:
            return try await tonTestnetBlocksController.getLastMasterBlock(req)
        case .getBlock:
            return try await tonTestnetBlocksController.getBlock(req)
        case .getRawBlock:
            return try await tonTestnetBlocksController.getRawBlock(req)
        case .lookupBlock:
            return try await tonTestnetBlocksController.lookupBlock(req)
        case .getBlockByTime:
            return try await tonTestnetBlocksController.getBlockByTime(req)
        case .estimateFee:
            return try await tonTestnetSendController.estimateFee(req)
        case .getBlocksTransactions:
            return try await tonTestnetTransactionsController.getBlocksTransactions(req)
        case .getJettonInfo:
            return try await tonTestnetJettonsController.getJettonInfo(req)
        case .convertAddress:
            return try await tonTestnetAccountsController.convertAddress(req)
        }
    }
}
