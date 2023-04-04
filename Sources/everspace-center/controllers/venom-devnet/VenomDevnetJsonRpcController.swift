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

public enum VenomDevnetRPCMethods: String, Content {
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

class VenomDevnetJsonRpcController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("jsonRpc", use: jsonRpc)
    }
    
    func jsonRpc(_ req: Request) async throws -> Response {
        let method: VenomDevnetRPCMethods = try req.content.decode(JsonRPCRequestMethod<VenomDevnetRPCMethods>.self).method
        
        switch method {
        case .getTransactions:
            return try await venomDevnetTransactionsController.getTransactions(req)
        case .getTransaction:
            return try await venomDevnetTransactionsController.getTransaction(req)
        case .getAccount:
            return try await venomDevnetAccountsController.getAccount(req)
        case .getBalance:
            return try await venomDevnetAccountsController.getBalance(req)
        case .sendExternalMessage:
            return try await venomDevnetSendController.sendExternalMessage(req)
        case .runGetMethodAbi:
            return try await venomDevnetRunGetMethodsController.runGetMethodAbi(req)
        case .runGetMethodFift:
            return try await venomDevnetRunGetMethodsController.runGetMethodFift(req)
        case .waitForTransaction:
            return try await venomDevnetSendController.waitForTransaction(req)
        case .getConfigParams:
            return try await venomDevnetBlocksController.getConfigParams(req)
        case .sendAndWaitTransaction:
            return try await venomDevnetSendController.sendAndWaitTransaction(req)
        case .getLastMasterBlock:
            return try await venomDevnetBlocksController.getLastMasterBlock(req)
        case .getBlock:
            return try await venomDevnetBlocksController.getBlock(req)
        case .getRawBlock:
            return try await venomDevnetBlocksController.getRawBlock(req)
        case .lookupBlock:
            return try await venomDevnetBlocksController.lookupBlock(req)
        case .getBlockByTime:
            return try await venomDevnetBlocksController.getBlockByTime(req)
        case .estimateFee:
            return try await venomDevnetSendController.estimateFee(req)
        case .getBlocksTransactions:
            return try await venomDevnetTransactionsController.getBlocksTransactions(req)
        case .convertAddress:
            return try await venomDevnetAccountsController.convertAddress(req)
        }
    }
}
