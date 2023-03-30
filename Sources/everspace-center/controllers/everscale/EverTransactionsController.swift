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
        routes.get("getBlocksTransactions", use: getBlocksTransactions)
    }
    
    func getTransactions(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: JsonRPCRequest<EverRPCMethods, GetTransactionsRequest> = try req.content.decode(JsonRPCRequest<EverRPCMethods, GetTransactionsRequest>.self)
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
            let content: JsonRPCRequest<EverRPCMethods, GetTransactionRequest> = try req.content.decode(JsonRPCRequest<EverRPCMethods, GetTransactionRequest>.self)
            result = JsonRPCResponse<Everscale.ExtendedTransactionHistoryModel>(id: content.id,
                                                                                result: try await getTransaction(client, content.params)).toJson()
        } else {
            let content: GetTransactionRequest = try req.query.decode(GetTransactionRequest.self)
            result = try await getTransaction(client, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func getBlocksTransactions(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: JsonRPCRequest<EverRPCMethods, Everscale.BlocksTransactionsRequest> = try req.content.decode(JsonRPCRequest<EverRPCMethods, Everscale.BlocksTransactionsRequest>.self)
            result = JsonRPCResponse<[BlocksTransactionsResponse]>(id: content.id,
                                                                   result: try await getBlocksTransactions(client, content.params)).toJson()
        } else {
            let content: Everscale.BlocksTransactionsRequest = try req.query.decode(Everscale.BlocksTransactionsRequest.self)
            result = try await getBlocksTransactions(client, content).toJson()
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
    
    struct BlocksTransactionsResponse: Content {
        var workchain_id: Int = 1
        var seq_no: Double = 1
        var shard: String = ""
        var id: String = ""
        var transactions: [Everscale.TransactionHistoryModel] = []
    }
    
    struct BlocksTransactionsResponseResult: Content {
        var transactions: [Everscale.TransactionHistoryModel] = []
    }
    
    func getTransactions(_ client: TSDKClientModule,
                         _ content: GetTransactionsRequest
    ) async throws -> [Everscale.TransactionHistoryModel] {
        let accountAddress: String = try await tonConvertAddrToEverFormat(client: client, content.address)
        let transactions = try await Everscale.getTransactions(client: client,
                                                               address: accountAddress,
                                                               limit: content.limit,
                                                               lt: content.lt,
                                                               to_lt: content.to_lt,
                                                               hashId: content.hash)
        return transactions
        //        if content.hash != nil || content.lt != nil || content.to_lt != nil {
        //            let transactions = try await Everscale.getTransactions(client: client,
        //                                                                   address: accountAddress,
        //                                                                   limit: content.limit,
        //                                                                   lt: content.lt,
        //                                                                   to_lt: content.to_lt,
        //                                                                   hashId: content.hash)
        //            return transactions
        //        } else {
        //            return try await withCheckedThrowingContinuation { continuation in
        //                Everscale.getTransactions(client: client, address: accountAddress, limit: content.limit) { result in
        //                    switch result {
        //                    case let .success(transactions):
        //                        continuation.resume(returning: transactions)
        //                    case let .failure(error):
        //                        continuation.resume(throwing: makeError(error))
        //                    }
        //                }
        //            }
        //        }
    }
    
    
    
    func getTransaction(_ client: TSDKClientModule,
                        _ content: GetTransactionRequest
    ) async throws -> Everscale.ExtendedTransactionHistoryModel {
        try await Everscale.getTransaction(client: client, hashId: content.hash)
    }
    
    
    //    blockchain {
    //      blocks(master_seq_no_range: {start: \(content.seq_no), end: \(content.seq_no + 1)}) {
    //        edges {
    //          node {
    //            id
    //            workchain_id
    //            shard
    //            account_blocks {
    //              transactions {
    //                transaction_id
    //              }
    //            }
    //          }
    //        }
    //      }
    //    }
    
    func getBlocksTransactions(_ client: TSDKClientModule,
                               _ content: Everscale.BlocksTransactionsRequest
    ) async throws -> [BlocksTransactionsResponse] {
        let out = try await Everscale.getBlocksTransactions(client: client, content: content)
        var cache_responses: [String: BlocksTransactionsResponse] = .init()
        var cache_transactions: [String: String] = .init()
        var ids: [String] = .init()
        
        for edge in out.blockchain.blocks.edges {
            var blocksTransactionsResponse: BlocksTransactionsResponse = .init()
            blocksTransactionsResponse.id = edge.node.id.replace(#"^block\/"#, "")
            blocksTransactionsResponse.seq_no = edge.node.seq_no
            blocksTransactionsResponse.shard = edge.node.shard
            blocksTransactionsResponse.workchain_id = edge.node.workchain_id
            let key: String = "\(blocksTransactionsResponse.shard)-\(blocksTransactionsResponse.workchain_id)"
            cache_responses[key] = blocksTransactionsResponse
            
            for accBlock in edge.node.account_blocks {
                for transaction in accBlock.transactions {
                    cache_transactions[transaction.transaction_id] = key
                    ids.append(transaction.transaction_id)
                }
            }
        }
        
        let out2 = try await client.net.query(TSDKParamsOfQuery(query: """
        query {
            transactions(
                filter: {id: {in: \(ids)}}
            ) {
                id account_addr balance_delta(format: DEC) in_message{id dst value(format: DEC) src body} out_messages{id dst value(format: DEC) body} out_msgs total_fees(format: DEC) now lt
            }
        }
        """))
        
        guard let full_transactions = try (out2.result.toDictionary()?["data"] as? [String: Any])?.toAnyValue().toModel(BlocksTransactionsResponseResult.self)
        else {
            throw makeError(AppError.mess("Bad transactions."))
        }
        
        for full_transaction in full_transactions.transactions {
            guard let block_key = cache_transactions[full_transaction.id] else {
                throw makeError(AppError.mess("Key by tx_id not found"))
            }
            cache_responses[block_key]?.transactions.append(full_transaction)
        }
        
        let result = cache_responses.values.sorted { $0.workchain_id < $1.workchain_id }
        
        return result
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
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/getBlocksTransactions",
                                      summary: "",
                                      description: "Get Transactions of Block by seq_no",
                                      parametersObject: Everscale.BlocksTransactionsRequest(),
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
            APIObject(object: Everscale.BlocksTransactionsRequest()),
        ])
    }
}
