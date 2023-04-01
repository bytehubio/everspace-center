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

public enum VenomRPCMethods: String, Content {
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

class VenomJsonRpcController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("jsonRpc", use: jsonRpc)
    }
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: VenomRPCMethods = try req.content.decode(JsonRPCRequestMethod<VenomRPCMethods>.self).method
        
        switch method {
        case .getTransactions:
            return try await venomTransactionsController.getTransactions(req)
        case .getTransaction:
            return try await venomTransactionsController.getTransaction(req)
        case .getAccount:
            return try await venomAccountsController.getAccount(req)
        case .getBalance:
            return try await venomAccountsController.getBalance(req)
        case .sendExternalMessage:
            return try await venomSendController.sendExternalMessage(req)
        case .runGetMethodAbi:
            return try await venomRunGetMethodsController.runGetMethodAbi(req)
        case .runGetMethodFift:
            return try await venomRunGetMethodsController.runGetMethodFift(req)
        case .waitForTransaction:
            return try await venomSendController.waitForTransaction(req)
        case .getConfigParams:
            return try await venomBlocksController.getConfigParams(req)
        case .sendAndWaitTransaction:
            return try await venomSendController.sendAndWaitTransaction(req)
        case .getLastMasterBlock:
            return try await venomBlocksController.getLastMasterBlock(req)
        case .getBlock:
            return try await venomBlocksController.getBlock(req)
        case .getRawBlock:
            return try await venomBlocksController.getRawBlock(req)
        case .lookupBlock:
            return try await venomBlocksController.lookupBlock(req)
        case .getBlockByTime:
            return try await venomBlocksController.getBlockByTime(req)
        case .estimateFee:
            return try await venomSendController.estimateFee(req)
        case .getBlocksTransactions:
            return try await venomTransactionsController.getBlocksTransactions(req)
        }
    }
}
