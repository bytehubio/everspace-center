//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.03.2023.
//

import Foundation
import SwiftExtensionsPack
import Vapor
import EverscaleClientSwift
import Swiftgger


final class EverTransactionsController: RouteCollection {
    
    typealias Response = String
    
    static let shared: EverTransactionsController = .init()
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("getTransactions", use: getTransactions)
        routes.get("getTransaction", use: getTransaction)
    }

    func getTransactions(_ req: Request) async throws -> Response {
        let content: GetTransactionsRequest = try req.query.decode(GetTransactionsRequest.self)
        return try await getTransactions(EverClient.shared.client, content).toJson()
    }
    
    func getTransactionsRpc(_ req: Request) async throws -> Response {
        let content: EverJsonRPCRequest<GetTransactionsRequest> = try req.content.decode(EverJsonRPCRequest<GetTransactionsRequest>.self)
        return try JsonRPCResponse<[EverClient.TransactionHistoryModel]>(id: content.id,
                                                                         result: try await getTransactions(EverClient.shared.client, content.params)).toJson()
    }
    
    func getTransaction(_ req: Request) async throws -> Response {
        let content: GetTransactionRequest = try req.query.decode(GetTransactionRequest.self)
        return try await getTransaction(EverClient.shared.client, content).toJson()
    }
    
    func getTransactionRpc(_ req: Request) async throws -> Response {
        let content: EverJsonRPCRequest<GetTransactionRequest> = try req.content.decode(EverJsonRPCRequest<GetTransactionRequest>.self)
        return try JsonRPCResponse<EverClient.ExtendedTransactionHistoryModel>(id: content.id,
                                                                               result: try await getTransaction(EverClient.shared.client, content.params)).toJson()
    }
}

extension EverTransactionsController {
    
    struct GetTransactionsRequest: Content {
        var address: String = ""
        var limit: UInt32? = nil
        var lt: String? = nil
        var to_lt: String? = nil
        var hash: String? = nil
    }
    
    struct GetTransactionRequest: Content {
        var hash: String = "..."
    }
    
    func getTransactions(_ client: TSDKClientModule,
                         _ content: GetTransactionsRequest
    ) async throws -> [EverClient.TransactionHistoryModel] {
        let accountAddress: String = try await tonConvertAddrToEverFormat(client: client, content.address)
        if content.hash != nil || content.lt != nil || content.to_lt != nil {
            let transactions = try await EverClient.getTransactions(address: accountAddress,
                                                                    limit: content.limit,
                                                                    lt: content.lt,
                                                                    to_lt: content.to_lt,
                                                                    hashId: content.hash)
            return transactions
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                EverClient.getTransactions(address: accountAddress, limit: content.limit) { result in
                    switch result {
                    case let .success(transactions):
                        continuation.resume(returning: transactions)
                    case let .failure(error):
                        continuation.resume(throwing: makeError(error))
                    }
                }
            }
        }
    }
    
    func getTransaction(_ client: TSDKClientModule,
                        _ content: GetTransactionRequest
    ) async throws -> EverClient.ExtendedTransactionHistoryModel {
        try await EverClient.getTransaction(client: client, hashId: content.hash)
    }

    @discardableResult
    func prepareSwagger(_ openAPIBuilder: OpenAPIBuilder) -> OpenAPIBuilder {
        return openAPIBuilder.add(
            APIController(name: "transactions",
                          description: "Transactions Controller",
                          actions: [
                APIAction(method: .get,
                          route: "/everscale/getTransactions",
                          summary: "",
                          description: "Get Account Transactions",
                          parametersObject: GetTransactionsRequest(),
                          responses: [
                            .init(code: "200",
                                  description: "Description",
                                  type: .object(JsonRPCResponse<[EverClient.TransactionHistoryModel]>.self, asCollection: false))
                          ]),
                APIAction(method: .get,
                          route: "/everscale/getTransaction",
                          summary: "",
                          description: "Get Extend Account Transaction",
                          parametersObject: GetTransactionRequest(),
                          responses: [
                            .init(code: "200",
                                  description: "Description",
                                  type: .object(JsonRPCResponse<EverClient.ExtendedTransactionHistoryModel>.self, asCollection: false))
                          ]),
            ])
        ).add([
            APIObject(object: JsonRPCResponse<[EverClient.TransactionHistoryModel]>(result: [.init()])),
            APIObject(object: JsonRPCResponse<EverClient.ExtendedTransactionHistoryModel>(result: .init())),
            APIObject(object: EverClient.TransactionHistoryModel()),
            APIObject(object: EverClient.TransactionHistoryModel.InMessage()),
            APIObject(object: EverClient.TransactionHistoryModel.OutMessage()),
            APIObject(object: EverClient.ExtendedTransactionHistoryModel()),
            APIObject(object: EverClient.ExtendedTransactionHistoryModel.TransactionCompute()),
        ])
    }
}
