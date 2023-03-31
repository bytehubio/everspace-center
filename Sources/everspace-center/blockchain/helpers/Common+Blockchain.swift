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
import BigInt

func tonConvertAddrToEverFormat(client: TSDKClientModule, _ address: String) async throws -> String {
    if address[#":"#] {
        return address.everAddrLowercased
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
        TSDKParamsOfConvertAddress(address: address.everAddrLowercased,
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
    let addr: String = try await tonConvertAddrToEverFormat(client: emptyClient, addr)
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

public final class TvmCellBuilder {
    
    private var ops: [TSDKBuilderOp] = .init()
    
    func build() -> [TSDKBuilderOp] {
        ops
    }
    
    @discardableResult
    func storeUInt(value: BigInt, size: UInt32) -> Self {
        ops.append(
            .init(
                type: .Integer,
                size: size,
                value: .string(String(value))
            )
        )
        return self
    }
    
    @discardableResult
    func storeBytes(value: String) -> Self {
        ops.append(
            .init(
                type: .BitString,
                value: .string(value)
            )
        )
        return self
    }
    
    @discardableResult
    func storeBit(value: Bit) -> Self {
        storeUInt(value: value.rawValue == 1 ? 1 : 0, size: 1)
        return self
    }
    
    @discardableResult
    func storeBits(bits: [Bit]) -> Self {
        bits.forEach { storeBit(value: $0) }
        return self
    }
    
    @discardableResult
    func storeCellRefFromBoc(value: String) -> Self {
        ops.append(
            .init(
                type: .CellBoc,
                boc: value
            )
        )
        return self
    }
    
    @discardableResult
    func storeCellRef(builder: [TSDKBuilderOp]) -> Self {
        ops.append(
            .init(
                type: .Cell,
                builder: builder
            )
        )
        return self
    }
    
    /// var_uint$_ {n:#} len:(#< n) value:(uint (len * 8)) = VarUInteger n;
    @discardableResult
    func storeVarUInt(value: BigInt, len: Int) throws -> Self {
        let size: UInt32 = UInt32(log2(Double(len)).round(toDecimalPlaces: 0, rule: .up))
        if value == 0 {
            storeUInt(value: 0, size: size)
        } else {
            let arr: [BigInt] = (0...BigInt(len)).map { $0 * 8 }
            guard let bitLen: BigInt = arr.filter({ value < (1 << $0) }).first else {
                throw makeError(AppError.mess("No value"))
            }
            storeUInt(value: BigInt((Double(bitLen) / 8).round(toDecimalPlaces: 0, rule: .up)), size: size)
            storeUInt(value: value, size: UInt32(bitLen))
        }
        return self
    }
    
    /// nanograms$_ amount:(VarUInteger 16) = Grams;
    @discardableResult
    func storeGrams(value: BigInt) throws -> Self {
        try storeVarUInt(value: value, len: 16)
    }
    
    @discardableResult
    func storeAddress(address: String) -> Self {
        if address.isEmpty {
            storeBits(bits: [.b0, .b0])
        } else {
            ops.append(
                .init(
                    type: .Address,
                    address: address
                )
            )
        }
        
        return self
    }
    
    @discardableResult
    func append(builder: TvmCellBuilder) -> Self {
        ops += builder.build()
        return self
    }
    
    @discardableResult
    func append(options: [TSDKBuilderOp]) -> Self {
        ops += options
        return self
    }
    
    public enum Bit: UInt32 {
        case b0
        case b1
    }
}
