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

public enum VenomTestnetRPCMethods: String, Content {
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
    case convertAddress
}

class VenomTestnetJsonRpcController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("jsonRpc", use: jsonRpc)
    }
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: VenomTestnetRPCMethods = try req.content.decode(JsonRPCRequestMethod<VenomTestnetRPCMethods>.self).method
        
        switch method {
        case .getTransactions:
            return try await venomTestnetTransactionsController.getTransactions(req)
        case .getTransaction:
            return try await venomTestnetTransactionsController.getTransaction(req)
        case .getAccount:
            return try await venomTestnetAccountsController.getAccount(req)
        case .getBalance:
            return try await venomTestnetAccountsController.getBalance(req)
        case .sendExternalMessage:
            return try await venomTestnetSendController.sendExternalMessage(req)
        case .runGetMethodAbi:
            return try await venomTestnetRunGetMethodsController.runGetMethodAbi(req)
        case .runGetMethodFift:
            return try await venomTestnetRunGetMethodsController.runGetMethodFift(req)
        case .waitForTransaction:
            return try await venomTestnetSendController.waitForTransaction(req)
        case .getConfigParams:
            return try await venomTestnetBlocksController.getConfigParams(req)
        case .sendAndWaitTransaction:
            return try await venomTestnetSendController.sendAndWaitTransaction(req)
        case .getLastMasterBlock:
            return try await venomTestnetBlocksController.getLastMasterBlock(req)
        case .getBlock:
            return try await venomTestnetBlocksController.getBlock(req)
        case .getRawBlock:
            return try await venomTestnetBlocksController.getRawBlock(req)
        case .lookupBlock:
            return try await venomTestnetBlocksController.lookupBlock(req)
        case .getBlockByTime:
            return try await venomTestnetBlocksController.getBlockByTime(req)
        case .estimateFee:
            return try await venomTestnetSendController.estimateFee(req)
        case .getBlocksTransactions:
            return try await venomTestnetTransactionsController.getBlocksTransactions(req)
        case .convertAddress:
            return try await venomTestnetAccountsController.convertAddress(req)
        }
    }
}
