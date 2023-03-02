//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.03.2023.
//

import Foundation
import EverscaleClientSwift
import BigInt
import SwiftExtensionsPack
import Vapor

extension EverClient {
    struct TransactionHistoryModel: Codable, Content {
        var id: String
        var account_addr: String
        var now: Double
        var total_fees: String
        var balance_delta: String
        var out_msgs: [String]
        var in_message: InMessage?
        var out_messages: [OutMessage]
        var lt: String
        var cursor: String?
        
        var isIncomingTransaction: Bool {
            out_messages.isEmpty
        }
        
        struct InMessage: Codable {
            var id: String
            var src: String
            var value: String?
            var dst: String
            var body: String?
        }
        
        struct OutMessage: Codable {
            var id: String
            var dst: String
            var value: String?
            var body: String?
        }
    }
    
    
    struct TransactionIds: Codable {
        var blockchain: BlockCain
        
        struct BlockCain: Codable {
            var account: Account
            
            struct Account: Codable {
                var transactions: Transactions
                
                struct Transactions: Codable {
                    var pageInfo: PageInfo
                    var edges: [Edge]
                    
                    struct PageInfo: Codable {
                        var startCursor: String
                        var endCursor: String
                    }
                    
                    struct Edge: Codable {
                        struct Node: Codable {
                            var hash: String
                        }
                        
                        var cursor: String
                        var node: Node
                    }
                }
            }
        }
    }
    
    
    class func getTransactions(client: TSDKClientModule = EverClient.shared.client,
                               address: String,
                               limit: UInt32? = nil,
                               cursor: String? = nil,
                               _ handler: @escaping (Result<[TransactionHistoryModel], TSDKClientError>) throws -> Void
    ) {
        let defaultLimit: UInt32 = 50
        do {
            var query: String = .init()
            if let cursor = cursor {
                query = """
query {
    blockchain {
        account(
            address: "\(address)"
        ) {
            transactions(
                last: \(limit ?? defaultLimit),
                before: "\(cursor)"
            ) {
                pageInfo {
                    startCursor
                    endCursor
                },
                edges {
                    cursor
                    node {
                        hash
                    }
                }
            }
        }
    }
}
"""
            } else {
                query = """
query {
    blockchain {
        account(
            address: "\(address)"
        ) {
            transactions(
                last: \(limit ?? defaultLimit)
            ) {
                pageInfo {
                    startCursor
                    endCursor
                },
                edges {
                    cursor
                    node {
                        hash
                    }
                }
            }
        }
    }
}
"""
            }
            
            let paramsOfQuery: TSDKParamsOfQuery = .init(query: query, variables: nil)
            try client.net.query(paramsOfQuery) { response in
                if response.finished {
                    if let error = response.error {
                        try handler(.failure(error))
                    } else {
                        if let data = response.result?.result.toDictionary()?["data"] as? [String: Any] {
                            let transactionIds: TransactionIds = try data.toAnyValue().toModel(TransactionIds.self)
                            let ids: [String] = transactionIds.blockchain.account.transactions.edges.map { $0.node.hash }
                            let paramsOfQueryCollection: TSDKParamsOfQueryCollection = .init(collection: "transactions",
                                                                                             filter: [
                                                                                                "id": ["in": ids]
                                                                                             ].toAnyValue(),
                                                                                             result: "id account_addr balance_delta(format: DEC) in_message{ id dst value(format: DEC) src body} out_messages{ id dst value(format: DEC) body} out_msgs total_fees(format: DEC) now lt",
                                                                                             order: [
                                                                                                TSDKOrderBy(path: "now", direction: .DESC),
                                                                                                TSDKOrderBy(path: "lt", direction: .DESC)
                                                                                             ])
                            var resultArray: [TransactionHistoryModel] = .init()
                            try client.net.query_collection(paramsOfQueryCollection)
                            { (response: TSDKBindingResponse<TSDKResultOfQueryCollection, TSDKClientError>) in
                                if response.finished {
                                    do {
                                        try resultWrapper(response, handler) { result, resultHandler in
                                            for transaction in result.result {
                                                var transactionHistoryModel = try transaction.toModel(TransactionHistoryModel.self)
                                                transactionIds.blockchain.account.transactions.edges.forEach {
                                                    let id: String = $0.node.hash
                                                    if transactionHistoryModel.id == id {
                                                        transactionHistoryModel.cursor = $0.cursor
                                                    }
                                                }
                                                resultArray.append(transactionHistoryModel)
                                            }
                                            try handler(.success(resultArray))
                                        }
                                    } catch let error {
                                        try? handler(.failure(makeError(TSDKClientError(error.localizedDescription))))
                                    }
                                }
                            }
                        } else {
                            try handler(.failure(makeError(TSDKClientError(code: 0, message: "getTransactions: data not found"))))
                        }
                    }
                }
            }
        } catch {
            try? handler(.failure(makeError(TSDKClientError(error))))
        }
    }
    
    
    //        func getTransactionsCount(client: TSDKClientModule = EverClient.shared.client,
    //                                  address: String,
    //                                  filter: AnyValue? = nil,
    //                                  _ handler: @escaping (Result<BigInt, TSDKClientError>) -> Void
    //        ) {
    //            let currentFilter: AnyValue = filter ?? ["account_addr": ["eq": address]].toAnyValue()
    //            let paramsOfAggregateCollection: TSDKParamsOfAggregateCollection = .init(collection: "transactions",
    //                                                                                     filter: currentFilter)
    //            print("asdf", "start getTransactionsCount")
    //            try client.net.aggregate_collection(paramsOfAggregateCollection)
    //            { (response: TSDKBindingResponse<TSDKResultOfAggregateCollection, TSDKClientError>) in
    //                print("asdf", "getTransactionsCount \(response.rawResponse)")
    //                if response.finished {
    //                    try resultWrapper(response, handler) { result, handler in
    //                        if
    //                            let values = result.values.toAny() as? Array<String>,
    //                            values.count > 0,
    //                            let bigInt: BigInt = BigInt(values[0])
    //                        {
    //                            try handler(.success(bigInt))
    //                        } else {
    //                            try handler(.success(0))
    //                        }
    //                    }
    //                }
    //            }
    //        }
    
    class func getTransactions(client: TSDKClientModule = EverClient.shared.client,
                               address: String,
                               limit: UInt32?,
                               lastLt: String? = nil,
                               hashId: String? = nil,
                               _ handler: @escaping (Result<[TransactionHistoryModel], TSDKClientError>) throws -> Void
    ) {
        let defaultLimit: UInt32 = 50
        do {
            var currentFilter: [String: Any] = ["account_addr": ["eq": address]]
            if let lastLt = lastLt {
                currentFilter["lt"] = ["lt": lastLt]
            } else if let hashId = hashId {
                currentFilter["id"] = ["eq": hashId]
            }
            let paramsOfQueryCollection: TSDKParamsOfQueryCollection = .init(collection: "transactions",
                                                                             filter: currentFilter.toAnyValue(),
                                                                             result: "id account_addr balance_delta(format: DEC) in_message{id dst value(format: DEC) src body} out_messages{id dst value(format: DEC) body} out_msgs total_fees(format: DEC) now lt",
                                                                             order: [
                                                                                TSDKOrderBy(path: "now", direction: .DESC),
                                                                                TSDKOrderBy(path: "lt", direction: .DESC)
                                                                             ],
                                                                             limit: limit ?? defaultLimit)
            
            var resultArray: [TransactionHistoryModel] = .init()
            try client.net.query_collection(paramsOfQueryCollection)
            { (response: TSDKBindingResponse<TSDKResultOfQueryCollection, TSDKClientError>) in
                if response.finished {
                    do {
                        try resultWrapper(response, handler) { result, resultHandler in
                            for transaction in result.result {
                                resultArray.append(try transaction.toModel(TransactionHistoryModel.self))
                            }
                            try handler(.success(resultArray))
                        }
                    } catch {
                        try handler(.failure(TSDKClientError(code: 0, message: error.localizedDescription, data: [:].toAnyValue())))
                    }
                }
            }
        } catch {
            try? handler(.failure(makeError(TSDKClientError.mess(error.localizedDescription))))
        }
    }
    
}
