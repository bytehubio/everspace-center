//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 26.03.2023.
//

import Foundation
import EverscaleClientSwift
import BigInt
import SwiftExtensionsPack
import Vapor

extension EverClient {
    
    struct GetAccountResult: Codable {
        var result: [GetAccount] = []
        
        public struct GetAccount: Codable {
            var id: String = ""
            var balance: String = ""
            var acc_type: Int = 1
            var acc_type_name: String = ""
            var boc: String = ""
            var code: String = ""
            var code_hash: String = ""
            var prev_code_hash: String = ""
            var workchain_id: Int = 1
            var data: String = ""
        }
    }
    
    class func getAccount(client: TSDKClientModule = EverClient.shared.client,
                          accountAddress: String
    ) async throws -> GetAccountResult.GetAccount {
        let response: [GetAccountResult.GetAccount] = try await getAccounts(accountAddresses: [accountAddress])
        
        if let first = response.first {
            return first
        } else {
            throw makeError(TSDKClientError.mess("Account not found"))
        }
    }
    
    class func getAccounts(client: TSDKClientModule = EverClient.shared.client,
                           accountAddresses: [String]
    ) async throws -> [GetAccountResult.GetAccount] {
        let paramsOfQueryCollection: TSDKParamsOfQueryCollection = .init(collection: "accounts",
                                                                         filter: [
                                                                            "id": [
                                                                                "in": accountAddresses
                                                                            ]
                                                                         ].toAnyValue(),
                                                                         result: [
                                                                            "id",
                                                                            "acc_type",
                                                                            "acc_type_name",
                                                                            "boc",
                                                                            "code",
                                                                            "code_hash",
                                                                            "prev_code_hash",
                                                                            "workchain_id",
                                                                            "data",
                                                                            "balance(format: DEC)",
                                                                         ].joined(separator: " "))
        let response: TSDKResultOfQueryCollection = try await client.net.query_collection(paramsOfQueryCollection)
        return try response.result.toJson().toModel([GetAccountResult.GetAccount].self)
    }
}
