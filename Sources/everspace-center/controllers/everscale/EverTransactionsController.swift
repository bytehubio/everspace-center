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


class EverTransactionsController: RouteCollection {
    var swagger: SwaggerControllerPrtcl
    var client: TSDKClientModule
    var emptyClient: TSDKClientModule = SDKClient.makeEmptyClient()
    
    init(_ client: TSDKClientModule, _ swagger: SwaggerControllerPrtcl) {
        self.client = client
        self.swagger = swagger
        prepareSwagger(swagger.openAPIBuilder)
    }
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("getTransactions", use: getTransactions)
        routes.get("getTransaction", use: getTransaction)
    }
    
    func getTransactions(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: EverJsonRPCRequest<GetTransactionsRequest> = try req.content.decode(EverJsonRPCRequest<GetTransactionsRequest>.self)
            result = JsonRPCResponse<[Everscale.TransactionHistoryModel]>(id: content.id,
                                                                            result: try await getTransactions(client, content.params)).toJson()
        } else {
            let content: GetTransactionsRequest = try req.query.decode(GetTransactionsRequest.self)
            result = try await getTransactions(client, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func getTransaction(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: EverJsonRPCRequest<GetTransactionRequest> = try req.content.decode(EverJsonRPCRequest<GetTransactionRequest>.self)
            result = JsonRPCResponse<Everscale.ExtendedTransactionHistoryModel>(id: content.id,
                                                                                  result: try await getTransaction(client, content.params)).toJson()
        } else {
            let content: GetTransactionRequest = try req.query.decode(GetTransactionRequest.self)
            result = try await getTransaction(client, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
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
    ) async throws -> [Everscale.TransactionHistoryModel] {
        let accountAddress: String = try await tonConvertAddrToEverFormat(client: client, content.address)
        if content.hash != nil || content.lt != nil || content.to_lt != nil {
            let transactions = try await Everscale.getTransactions(client: client,
                                                                   address: accountAddress,
                                                                   limit: content.limit,
                                                                   lt: content.lt,
                                                                   to_lt: content.to_lt,
                                                                   hashId: content.hash)
            return transactions
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                Everscale.getTransactions(client: client, address: accountAddress, limit: content.limit) { result in
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
    ) async throws -> Everscale.ExtendedTransactionHistoryModel {
        try await Everscale.getTransaction(client: client, hashId: content.hash)
    }
    
    @discardableResult
    func prepareSwagger(_ openAPIBuilder: OpenAPIBuilder) -> OpenAPIBuilder {
        return openAPIBuilder.add(
            APIController(name: "transactions",
                          description: "Transactions Controller",
                          actions: [
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/getTransactions",
                                      summary: "",
                                      description: "Get Account Transactions",
                                      parametersObject: GetTransactionsRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<[Everscale.TransactionHistoryModel]>.self, asCollection: false))
                                      ]),
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/getTransaction",
                                      summary: "",
                                      description: "Get Extend Account Transaction",
                                      parametersObject: GetTransactionRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<Everscale.ExtendedTransactionHistoryModel>.self, asCollection: false))
                                      ]),
                          ])
        ).add([
            APIObject(object: JsonRPCResponse<[Everscale.TransactionHistoryModel]>(result: [.init()])),
            APIObject(object: JsonRPCResponse<Everscale.ExtendedTransactionHistoryModel>(result: .init())),
            APIObject(object: Everscale.TransactionHistoryModel()),
            APIObject(object: Everscale.TransactionHistoryModel.InMessage()),
            APIObject(object: Everscale.TransactionHistoryModel.OutMessage()),
            APIObject(object: Everscale.ExtendedTransactionHistoryModel()),
            APIObject(object: Everscale.ExtendedTransactionHistoryModel.TransactionCompute()),
        ])
    }
}
