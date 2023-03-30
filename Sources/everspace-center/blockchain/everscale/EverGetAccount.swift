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

extension Everscale {
    
    public struct Account: Codable {
        var id: String = ""
        var balance: String = ""
        var acc_type: Int = 1
        var acc_type_name: String? = ""
        var code: String? = ""
        var code_hash: String? = ""
        var due_payment: String? = ""
        var workchain_id: Int = 1
        var library_hash: String? = ""
        var library: String? = ""
        var data: String? = ""
        var data_hash: String? = ""
    }
    
    public struct AccountBalance: Codable {
        var id: String = ""
        var balance: String = ""
    }
    
    class func getAccount(client: TSDKClientModule,
                          accountAddress: String
    ) async throws -> Account {
        let accountAddress: String = try await tonConvertAddrToEverFormat(client: client, accountAddress)
        let response: [Account] = try await getAccounts(client: client, accountAddresses: [accountAddress])
        if let first = response.first {
            return first
        } else {
            throw makeError(TSDKClientError.mess("Account not found"))
        }
    }
    
    class func getAccounts(client: TSDKClientModule,
                           accountAddresses: [String]
    ) async throws -> [Account] {
        var addresses: [String] = []
        for address in accountAddresses {
            addresses.append(try await tonConvertAddrToEverFormat(client: client, address))
        }
        let paramsOfQueryCollection: TSDKParamsOfQueryCollection = .init(collection: "accounts",
                                                                         filter: [
                                                                            "id": [
                                                                                "in": addresses
                                                                            ]
                                                                         ].toAnyValue(),
                                                                         result: [
                                                                            "id",
                                                                            "balance(format: DEC)",
                                                                            "acc_type",
                                                                            "acc_type_name",
                                                                            "code",
                                                                            "code_hash",
                                                                            "data",
                                                                            "data_hash",
                                                                            "library",
                                                                            "library_hash",
                                                                            "due_payment(format: DEC)",
                                                                            "workchain_id",
                                                                         ].joined(separator: " "))
        let response: TSDKResultOfQueryCollection = try await client.net.query_collection(paramsOfQueryCollection)
        return try response.result.toJson().toModel([Account].self)
    }
    
    class func getBalance(client: TSDKClientModule,
                          accountAddress: String
    ) async throws -> AccountBalance {
        let accountAddress: String = try await tonConvertAddrToEverFormat(client: client, accountAddress)
        let paramsOfQueryCollection: TSDKParamsOfQueryCollection = .init(collection: "accounts",
                                                                         filter: [
                                                                            "id": [
                                                                                "eq": accountAddress
                                                                            ]
                                                                         ].toAnyValue(),
                                                                         result: [
                                                                            "id",
                                                                            "balance(format: DEC)",
                                                                         ].joined(separator: " "))
        let response: TSDKResultOfQueryCollection = try await client.net.query_collection(paramsOfQueryCollection)
        
        
        
        if let first = try response.result.toJson().toModel([AccountBalance].self).first {
            return first
        } else {
            throw makeError(TSDKClientError.mess("Account not found"))
        }
    }
}
