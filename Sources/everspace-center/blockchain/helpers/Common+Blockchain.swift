//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 26.03.2023.
//

import Foundation
import Vapor
import EverscaleClientSwift
import SwiftExtensionsPack


func tonConvertAddrToEverFormat(client: TSDKClientModule, _ address: String) async throws -> String {
    if address[#":"#] {
        return address
    } else {
        let newAddr: TSDKResultOfConvertAddress = try await client.utils.convert_address(
            TSDKParamsOfConvertAddress(address: address,
                                       output_format: TSDKAddressStringFormat(type: .AccountId))
        )
        if newAddr.address[#":"#] {
            return newAddr.address
        } else {
            let wc: UInt8 = address.base64ToByteArray()[1]
            return "\(wc):\(newAddr.address)"
        }
    }
}

func tonConvertAddrToToncoinFormat(client: TSDKClientModule, _ address: String) async throws -> String {
    let model = try await client.utils.convert_address(
        TSDKParamsOfConvertAddress(address: address,
                                   output_format: TSDKAddressStringFormat(type: .Base64,
                                                                          url: true,
                                                                          test: false,
                                                                          bounce: true)))
    return model.address
}

func runGetMethodFift(client: TSDKClientModule,
                      emptyClient: TSDKClientModule,
                      addr: String,
                      method: String,
                      params: [Any]? = nil
) async throws -> TSDKResultOfRunGet {
    let paramsOfQueryCollection: TSDKParamsOfQueryCollection = .init(collection: "accounts",
                                                                     filter: [
                                                                        "id": [
                                                                            "eq": addr
                                                                        ]
                                                                     ].toAnyValue(),
                                                                     result: "boc")
    
    let result = try await client.net.query_collection(paramsOfQueryCollection)
    var boc: String = ""
    if let anyResult = result.result.map({ $0.toAny() }).first as? [String: Any] {
        if let resultBoc: String = anyResult["boc"] as? String {
            boc = resultBoc
        } else {
            throw makeError(TSDKClientError(code: 0, message: "Receive result, but Boc not found"))
        }
    } else {
        throw makeError(TSDKClientError(code: 0, message: "Boc not found"))
    }
    
    let paramsOfRunGet: TSDKParamsOfRunGet = .init(account: boc,
                                                   function_name: method,
                                                   input: (params ?? []).toAnyValue(),
                                                   execution_options: nil,
                                                   tuple_list_as_array: nil)
    return try await emptyClient.tvm.run_get(paramsOfRunGet)
}


func runGetMethodAbi(client: TSDKClientModule,
                     emptyClient: TSDKClientModule,
                     addr: String,
                     method: String,
                     params: [String: Any] = [:],
                     abi: String
) async throws -> String {
    let paramsOfQueryCollection: TSDKParamsOfQueryCollection = .init(collection: "accounts",
                                                                     filter: [
                                                                        "id": [
                                                                            "eq": addr
                                                                        ]
                                                                     ].toAnyValue(),
                                                                     result: "boc")
    
    let queryResponse = try await client.net.query_collection(paramsOfQueryCollection)
    
    var boc: String = ""
    if let anyResult = queryResponse.result.map({ $0.toAny() }).first as? [String: Any] {
        if let resultBoc: String = anyResult["boc"] as? String {
            boc = resultBoc
        } else {
            throw makeError(AppError.mess("Receive result, but Boc not found"))
        }
    } else {
        throw TSDKClientError(code: 0, message: "Boc not found")
    }
    guard let abi: AnyValue = abi.toDictionary()?.toAnyValue() else {
        throw makeError(AppError.mess("Abi converte failed. Bad Abi."))
    }
    
    let paramsOfEncodeMessage: TSDKParamsOfEncodeMessage = .init(
        abi: .init(type: .Serialized, value: abi),
        address: addr,
        deploy_set: nil,
        call_set: .init(
            function_name: method,
            header: nil,
            input: params.toAnyValue()
        ),
        signer: .init(type: .None),
        processing_try_index: nil
    )
    
    let encodedMessage = try await emptyClient.abi.encode_message(paramsOfEncodeMessage)
    
    let paramsOfRunTvm: TSDKParamsOfRunTvm = .init(message: encodedMessage.message,
                                                   account: boc,
                                                   execution_options: nil,
                                                   abi: TSDKAbi(type: .Serialized, value: abi),
                                                   boc_cache: nil,
                                                   return_updated_account: nil)
    
    let result = try await emptyClient.tvm.run_tvm(paramsOfRunTvm)
    if let output: String = result.decoded?.output?.toJSON() {
        return output
    } else {
        throw makeError(AppError.mess("Bad output"))
    }
}
