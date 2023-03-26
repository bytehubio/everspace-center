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


final class TransactionsController: RouteCollection {
    
    typealias ResponseValue = [EverClient.TransactionHistoryModel]
    typealias Response = String
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("everscale_getTransactions", use: getTransactions)
    }

    func getTransactions(_ req: Request) async throws -> Response {
        let content: GetTransactionsRequest = try req.query.decode(GetTransactionsRequest.self)
        return try await getTransactions(EverClient.shared.client, content).toJson()
    }
    
    func getTransactionsRpc(_ req: Request) async throws -> Response {
        let content: JsonRPCRequest<GetTransactionsRequest> = try req.content.decode(JsonRPCRequest<GetTransactionsRequest>.self)
        return try JsonRPCResponse<ResponseValue>(id: content.id,
                                                  result: try await getTransactions(EverClient.shared.client, content.params)).toJson()
    }
}

extension TransactionsController {
    
    struct GetTransactionsRequest: Content {
        var address: String = ""
        var limit: UInt32? = nil
        var lt: String? = nil
        var to_lt: String? = nil
        var hash: String? = nil
    }
    
    func getTransactions(_ client: TSDKClientModule,
                         _ content: GetTransactionsRequest
    ) async throws -> ResponseValue {
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

    @discardableResult
    func prepareSwagger(_ openAPIBuilder: OpenAPIBuilder) -> OpenAPIBuilder {
        return openAPIBuilder.add(
            APIController(name: "transactions",
                          description: "Controller where we can manage users",
                          actions: [
                APIAction(method: .get,
                          route: "/everscale_getTransactions",
                          summary: "",
                          description: "Get Account Transactions",
                          parametersObject: GetTransactionsRequest(),
                          responses: [
                            .init(code: "200",
                                  description: "Specific user",
                                  type: .object(JsonRPCResponse<ResponseValue>.self, asCollection: false))
                          ])
            ])
        ).add([
            APIObject(object: JsonRPCResponse<ResponseValue>(result: [.init()])),
            APIObject(object: EverClient.TransactionHistoryModel()),
            APIObject(object: EverClient.TransactionHistoryModel.InMessage()),
            APIObject(object: EverClient.TransactionHistoryModel.OutMessage()),
        ])
    }
}
