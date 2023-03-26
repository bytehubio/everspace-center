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
import AnyCodable


final class TransactionsController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("getTransactions", use: getTransactions)
    }

    func getTransactions(_ req: Request) async throws -> Response {
        let content: GetTransactionsRequest = try req.query.decode(GetTransactionsRequest.self)
        return try await getTransactions(content).toJson()
    }
    
    func getTransactionsRpc(_ req: Request) async throws -> Response {
        let content: JsonRPCRequest<GetTransactionsRequest> = try req.content.decode(JsonRPCRequest<GetTransactionsRequest>.self)
        return try JsonRPCResponse<ResponseValue>(id: content.id, result: try await getTransactions(content.params)).toJson()
    }
}

extension TransactionsController {
    
    typealias ResponseValue = [EverClient.TransactionHistoryModel]
    typealias Response = String
    
    struct GetTransactionsRequest: Content {
        var address: String = ""
        var limit: UInt32? = nil
        var lt: String? = nil
        var to_lt: String? = nil
        var hash: String? = nil
    }
    
    private func getTransactions(_ content: GetTransactionsRequest) async throws -> ResponseValue {
        if content.hash != nil || content.lt != nil || content.to_lt != nil {
            let transactions = try await EverClient.getTransactions(address: content.address,
                                                                    limit: content.limit,
                                                                    lt: content.lt,
                                                                    to_lt: content.to_lt,
                                                                    hashId: content.hash)
            return transactions
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                EverClient.getTransactions(address: content.address, limit: content.limit) { result in
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
}

extension TransactionsController {
    @discardableResult
    func prepareSwagger(_ openAPIBuilder: OpenAPIBuilder) -> OpenAPIBuilder {
        let transactions: ResponseValue = try! #"[{"id":"ce29b061719af6eb702aaa98b0814d3d809570227eb1ccc4b522478bed3d1309","account_addr":"0:93c5a151850b16de3cb2d87782674bc5efe23e6793d343aa096384aafd70812c","now":1679700641.0,"total_fees":"19197037","balance_delta":"890802963","out_msgs":["8cd24f0dcc6e6b3b9d32376aa27b40c796cbfe265932031a1f1fef1165b79266"],"in_message":{"id":"24ebd401d440dd8bb30494b01df620adc453de55a03e28f777a1b2313fef87cf","src":"-1:c0e135614417ead123d19aad936d378877b27d2ec21125923e089549408e9061","value":"910000000","dst":"0:93c5a151850b16de3cb2d87782674bc5efe23e6793d343aa096384aafd70812c","body":"te6ccgEBAQEANAAAYyZ9eC4AAAAAAAAD+wAAAACf5mZmZmZmZmZmZmZmZmZmZmZmZmZmZmZmZmZmZmZmZmZw"},"out_messages":[{"id":"8cd24f0dcc6e6b3b9d32376aa27b40c796cbfe265932031a1f1fef1165b79266","dst":"","body":"te6ccgEBAQEAEgAAICHqhGUAAAAAZB4ykAAAAAA="}],"lt":"0x213fa44a77c1"}]"#.toModel(ResponseValue.self)
        
        let getTransactions: JsonRPCResponse<ResponseValue> = .init(result: transactions)
        
        return openAPIBuilder.add(
            APIController(name: "transactions",
                          description: "Controller where we can manage users",
                          actions: [
                APIAction(method: .get,
                          route: "/getTransactions",
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
            APIObject(object: getTransactions),
            APIObject(object: transactions.first!),
        ])
    }
}


struct User: Codable, Content {
    var id: String
}
