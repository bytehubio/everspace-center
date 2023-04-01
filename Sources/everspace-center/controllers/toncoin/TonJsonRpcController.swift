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
    case getBlockByTime
    case estimateFee
    case getBlocksTransactions
    case getJettonInfo
}

class TonJsonRpcController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("jsonRpc", use: jsonRpc)
    }
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: TonRPCMethods = try req.content.decode(JsonRPCRequestMethod<TonRPCMethods>.self).method
        
        switch method {
        case .getTransactions:
            return try await tonTransactionsController.getTransactions(req)
        case .getTransaction:
            return try await tonTransactionsController.getTransaction(req)
        case .getAccount:
            return try await tonAccountsController.getAccount(req)
        case .getBalance:
            return try await tonAccountsController.getBalance(req)
        case .sendExternalMessage:
            return try await tonSendController.sendExternalMessage(req)
        case .runGetMethodAbi:
            return try await tonRunGetMethodsController.runGetMethodAbi(req)
        case .runGetMethodFift:
            return try await tonRunGetMethodsController.runGetMethodFift(req)
        case .waitForTransaction:
            return try await tonSendController.waitForTransaction(req)
        case .getConfigParams:
            return try await tonBlocksController.getConfigParams(req)
        case .sendAndWaitTransaction:
            return try await tonSendController.sendAndWaitTransaction(req)
        case .getLastMasterBlock:
            return try await tonBlocksController.getLastMasterBlock(req)
        case .getBlock:
            return try await tonBlocksController.getBlock(req)
        case .getRawBlock:
            return try await tonBlocksController.getRawBlock(req)
        case .lookupBlock:
            return try await tonBlocksController.lookupBlock(req)
        case .getBlockByTime:
            return try await tonBlocksController.getBlockByTime(req)
        case .estimateFee:
            return try await tonSendController.estimateFee(req)
        case .getBlocksTransactions:
            return try await tonTransactionsController.getBlocksTransactions(req)
        case .getJettonInfo:
            return try await tonJettonsController.getJettonInfo(req)
        }
    }
}
