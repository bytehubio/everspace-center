//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.03.2023.
//

import Foundation
import EverscaleClientSwift
import BigInt
import func SwiftExtensionsPack.makeError
import Vapor

extension Everscale {
    struct TransactionHistoryModel: Codable, Content {
        var id: String = "..."
        var account_addr: String? = "..."
        var now: Double? = 1
        var total_fees: String? = "..."
        var balance_delta: String? = "..."
        var out_msgs: [String] = ["..."]
        var in_message: InMessage? = .init()
        var out_messages: [OutMessage] = [.init()]
        var lt: String? = "..."
        var cursor: String? = "..."
        
        var isIncomingTransaction: Bool {
            out_messages.isEmpty
        }
        
        struct InMessage: Codable {
            var id: String = "..."
            var src: String = "..."
            var value: String? = "..."
            var dst: String = "..."
            var body: String? = "..."
        }
        
        struct OutMessage: Codable {
            var id: String = "..."
            var dst: String = "..."
            var value: String? = "..."
            var body: String? = "..."
        }
    }
    
    struct ExtendedTransactionHistoryModel: Codable, Content {
        var id: String = "..."
        var account_addr: String? = "..."
        var now: Double? = 1
        var total_fees: String? = "..."
        var balance_delta: String? = "..."
        var out_msgs: [String] = ["..."]
        var in_message: InMessage? = .init()
        var out_messages: [OutMessage] = [.init()]
        var lt: String? = "..."
        var compute: TransactionCompute? = .init()
        var destroyed: Bool? = false
        var end_status_name: String? = "..."
        var ext_in_msg_fee: String? = "..."
        var cursor: String? = "..."
        
        var isIncomingTransaction: Bool {
            out_messages.isEmpty
        }
        
        struct InMessage: Codable {
            var id: String = "..."
            var src: String = "..."
            var value: String? = "..."
            var dst: String = "..."
            var body: String? = "..."
        }
        
        struct OutMessage: Codable {
            var id: String = "..."
            var dst: String = "..."
            var value: String? = "..."
            var body: String = "..."
            var boc: String = "..."
            var bounce: Bool? = false
            var bounced: Bool? = false
            var created_lt: String = "..."
            var fwd_fee: String? = "..."
            var msg_type_name: String = "..."
        }
        
        struct TransactionCompute: Codable {
            var account_activated: Bool = false
            var compute_type: Int = 1
            var exit_code: Int = 1
            var gas_credit: Int? = 1
            var gas_fees: String = "..."
            var gas_limit: String = "..."
            var gas_used: String = "..."
            var vm_steps: Double = 1
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
    
    struct BlocksTransactionsRequest: Content {
        var seq_no: Int = 1
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
    
    struct BlocksTransactionsGQLResponse: Content {
        var blockchain: Blockchain = .init()
        
        struct Blockchain: Content {
            var blocks: Block = .init()
            
            struct Block: Content {
                var edges: [Edge] = []
                
                struct Edge: Content {
                    var node: Node = .init()
                    
                    struct Node: Content {
                        var id: String = ""
                        var seq_no: Double = 0
                        var workchain_id: Int = 0
                        var shard: String = ""
                        var account_blocks: [AccountBlock]? = []
                        
                        struct AccountBlock: Content {
                            var transactions: [Transaction] = []
                            
                            struct Transaction: Content {
                                var transaction_id: String = ""
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    class func getTransactions(client: TSDKClientModule,
                               address: String,
                               limit: UInt32? = nil,
                               cursor: String? = nil,
                               _ handler: @escaping (Result<[TransactionHistoryModel], TSDKClientError>) throws -> Void
    ) {
        let defaultLimit: UInt32 = 50
        do {
            var query: String = .init()
            query = """
query {
    blockchain {
        account(
            address: "\(address.everAddrLowercased)"
        ) {
            transactions(
                \(cursor.isNil ? "" : "before: \"\(cursor!)\",")
                last: \(limit ?? defaultLimit),
                archive: true
            ) {
                pageInfo {
                    startCursor
                    endCursor
                },
                edges {
                    cursor
                    node {
                        id
                        hash
                        account_addr
                        balance_delta(format: DEC)
                        in_message{ id hash value(format: DEC) src body}
                        out_messages{ id hash dst value(format: DEC) body}
                        now
                        lt
                    }
                }
            }
        }
    }
}
"""            
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
    
    
    
    class func getTransactions(client: TSDKClientModule,
                               address: String,
                               limit: UInt32?,
                               lt: String? = nil,
                               to_lt: String? = nil,
                               hashId: String? = nil,
                               tempArray: [TransactionHistoryModel] = []
    ) async throws -> [TransactionHistoryModel] {
        let address: String = try await tonConvertAddrToEverFormat(client, address.everAddrLowercased)
        let defaultLimit: UInt32 = 50
        if tempArray.count >= limit ?? defaultLimit { return tempArray }
        
        var currentFilter: [String: Any] = ["account_addr": ["eq": address]]
        if let lt = lt {
            currentFilter["lt"] = ["lt": lt]
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
        
        var resultArray: [TransactionHistoryModel] = tempArray
        let transactions = try await client.net.query_collection(paramsOfQueryCollection).result
        for transaction in transactions {
            let tx: TransactionHistoryModel = try transaction.toModel(TransactionHistoryModel.self)
            if
                let intLt = to_lt?.toDecimalFromHex(),
                let intLt2 = tx.lt?.toDecimalFromHex()
            {
                if intLt >= intLt2 {
                    resultArray.append(tx)
                    return resultArray
                }
            }
            resultArray.append(tx)
        }
        if transactions.isEmpty { return resultArray }
        let lastTransaction: TransactionHistoryModel = try transactions.last!.toModel(TransactionHistoryModel.self)
        if resultArray.last?.lt == lastTransaction.lt { return resultArray }
        return try await getTransactions(client: client,
                                         address: address,
                                         limit: limit ?? defaultLimit,
                                         lt: lt,
                                         to_lt: to_lt,
                                         hashId: hashId,
                                         tempArray: resultArray)
        
    }
    
    class func getTransaction(client: TSDKClientModule,
                              hashId: String? = nil
    ) async throws -> ExtendedTransactionHistoryModel {
        let paramsOfQueryCollection: TSDKParamsOfQueryCollection = .init(collection: "transactions",
                                                                         filter: ["id": ["eq": hashId]].toAnyValue(),
                                                                         result: [
                                                                            "id",
                                                                            "account_addr",
                                                                            "balance_delta(format: DEC)",
                                                                            "in_message{id dst value(format: DEC) src body}",
                                                                            "out_messages{id dst value(format: DEC) body boc bounce bounced created_lt(format: DEC) fwd_fee(format: DEC) msg_type_name}",
                                                                            "out_msgs",
                                                                            "total_fees(format: DEC)",
                                                                            "now",
                                                                            "lt",
                                                                            "compute{ account_activated compute_type exit_code gas_credit gas_fees(format: DEC) gas_limit(format: DEC) gas_used(format: DEC) vm_steps }",
                                                                            "destroyed",
                                                                            "end_status_name",
                                                                            "ext_in_msg_fee(format: DEC)"
                                                                         ].joined(separator: " ")
        )
        
        let transactions = try await client.net.query_collection(paramsOfQueryCollection).result
        
        if let transaction = try transactions.first?.toModel(ExtendedTransactionHistoryModel.self) {
            return transaction
        } else {
            throw makeError(AppError(reason: "Convert to ExtendedTransactionHistoryModel failed"))
        }
    }
    
    class func getBlocksTransactions(client: TSDKClientModule, content: BlocksTransactionsRequest) async throws -> BlocksTransactionsGQLResponse {
        let out = try await client.net.query(TSDKParamsOfQuery(query: """
        query {
          blockchain {
            blocks(master_seq_no_range: {start: \(content.seq_no), end: \(content.seq_no + 1)}) {
              edges {
                node {
                  id
                  workchain_id
                  shard
                  seq_no
                  account_blocks {
                    transactions {
                      transaction_id
                    }
                  }
                }
              }
            }
          }
        }
        """))
        
        guard let result = try (out.result.toDictionary()?["data"] as? [String: Any])?.toJSON().toModel(BlocksTransactionsGQLResponse.self)
        else {
            throw makeError(AppError.mess("Transactions not found"))
        }
        
        return result
    }
}
