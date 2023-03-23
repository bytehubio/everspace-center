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

final class TransactionsController {
    
    typealias ResponseValue = [EverClient.TransactionHistoryModel]
    typealias Response = String
    
    struct GetTransactionsRequest: Content {
        var address: String
        var limit: UInt32?
        var lt: String?
        var to_lt: String?
        var hash: String?
    }
    
    func getTransactionsRpc(_ req: Request) async throws -> Response {
        let content: JsonRPCRequest<GetTransactionsRequest> = try req.content.decode(JsonRPCRequest<GetTransactionsRequest>.self)
        return try await getTransactions(content)
    }
    
    private func getTransactions(_ content: JsonRPCRequest<GetTransactionsRequest>) async throws -> Response {
        if content.params.hash != nil || content.params.lt != nil || content.params.to_lt != nil {
            let transactions = try await EverClient.getTransactions(address: content.params.address,
                                                                    limit: content.params.limit,
                                                                    lt: content.params.lt,
                                                                    to_lt: content.params.to_lt,
                                                                    hashId: content.params.hash)
            return try JsonRPCResponse<ResponseValue>(id: content.id, result: transactions).toJson()
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                EverClient.getTransactions(address: content.params.address, limit: content.params.limit) { result in
                    switch result {
                    case let .success(transactions):
                        continuation.resume(returning: try JsonRPCResponse<ResponseValue>(id: content.id, result: transactions).toJson())
                    case let .failure(error):
                        continuation.resume(throwing: makeError(error))
                    }
                }
            }
        }
    }
}

extension TransactionsController: RouteCollection {
    
    //    func getTransactions(_ req: Request) async throws -> Response {
    //        let content: JsonRPCRequest<GetTransactionsRequest> = try req.query.decode(JsonRPCRequest<GetTransactionsRequest>.self)
    //        return try await getTransactions(content)
    //    }
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        //        routes.get("getTransactions", use: getTransactions)
    }
}
