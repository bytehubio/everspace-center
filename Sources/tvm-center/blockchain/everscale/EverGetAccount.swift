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
        var boc: String? = ""
    }
    
    public struct AccountBalance: Codable {
        var id: String = ""
        var balance: String = ""
    }
    
    class func getAccount(client: TSDKClientModule,
                          accountAddress: String
    ) async throws -> Account {
        let accountAddress: String = try await Everscale.tonConvertAddrToEverFormat(client, accountAddress.everAddrLowercased)
        let response: [Account] = try await getAccounts(client: client, accountAddresses: [accountAddress])
        if let first = response.first {
            return first
        } else {
            throw makeError(TSDKClientError.mess("Account not found"))
        }
    }
    
    class func getAccounts(client: TSDKClientModule,
                           accountAddresses: [String]? = [],
                           order: TSDKSortDirection? = .ASC,
                           limit: UInt32? = 1,
                           code_hash: String? = nil,
                           from_id: String? = nil,
                           workchain_id: Int? = nil
    ) async throws -> [Account] {
        var addresses: [String] = []
        for address in accountAddresses ?? [] {
            addresses.append(try await Everscale.tonConvertAddrToEverFormat(client, address.everAddrLowercased))
        }
        var filter: [String: Any] = .init()
        if accountAddresses != nil {
            filter["id"] = ["in": addresses]
        } else if let code_hash = code_hash {
            filter["code_hash"] = ["eq": code_hash]
        } else if let from_id = from_id {
            if order == .ASC {
                filter["id"] = ["gt": from_id]
            } else {
                filter["id"] = ["lt": from_id]
            }
        } else if let workchain_id = workchain_id {
            filter["workchain_id"] = ["eq": workchain_id]
        }
        let paramsOfQueryCollection: TSDKParamsOfQueryCollection = .init(collection: "accounts",
                                                                         filter: filter.toAnyValue(),
                                                                         result: [
                                                                            "id",
                                                                            "balance(format: DEC)",
                                                                            "acc_type",
                                                                            "acc_type_name",
                                                                            "code",
                                                                            "code_hash",
                                                                            "data",
                                                                            "data_hash",
                                                                            "boc",
                                                                            "library",
                                                                            "library_hash",
                                                                            "due_payment(format: DEC)",
                                                                            "workchain_id",
                                                                         ].joined(separator: " "),
                                                                         order: [
                                                                            .init(path: "id", direction: order ?? .ASC)
                                                                         ],
                                                                         limit: limit)
        let response: TSDKResultOfQueryCollection = try await client.net.query_collection(paramsOfQueryCollection)
        return try response.result.toJson().toModel([Account].self)
    }
    
    class func getBalance(client: TSDKClientModule,
                          accountAddress: String
    ) async throws -> AccountBalance {
        let accountAddress: String = try await Everscale.tonConvertAddrToEverFormat(client, accountAddress.everAddrLowercased)
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
    
    class func tonConvertAddrToToncoinFormat(_ emptyClient: TSDKClientModule, _ address: String, _ bounce: Bool = true) async throws -> String {
        let model = try await emptyClient.utils.convert_address(
            TSDKParamsOfConvertAddress(address: address,
                                       output_format: TSDKAddressStringFormat(type: .Base64,
                                                                              url: true,
                                                                              test: false,
                                                                              bounce: bounce)))
        return model.address
    }
    
    class func tonConvertAddrToEverFormat(_ emptyClient: TSDKClientModule, _ address: String) async throws -> String {
        if address[#":"#] {
            return address
        } else {
            let newAddr: TSDKResultOfConvertAddress = try await emptyClient.utils.convert_address(
                TSDKParamsOfConvertAddress(address: address,
                                           output_format: TSDKAddressStringFormat(type: .Hex))
            )
            if newAddr.address[#":"#] {
                return newAddr.address
            } else {
                if address.base64ToByteArray()[1] > Int8.max || address.base64ToByteArray()[1] < Int8.min {
                    throw makeError(AppError("\(address.base64ToByteArray()[1]) overflow"))
                }
                let wc: Int8 = Int8(bitPattern: address.base64ToByteArray()[1])
                return "\(wc):\(newAddr.address)"
            }
        }
    }
}
