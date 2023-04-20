//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 01.04.2023.
//

import Foundation
import EverscaleClientSwift
import SwiftExtensionsPack
import Vapor

extension Toncoin {
    struct ToncoinJettonInfo: Content {
        public var name: String = ""
        public var symbol: String = ""
        public var decimals: Int = 9
        public var image: String? = nil
    }
    
    struct ToncoinJettonInfoModel: Content {
        public var name: String = ""
        public var symbol: String = ""
        public var decimals: Int? = nil
        public var image: String? = nil
        public var image_data: String? = nil
    }
    
    class func tonGetJettonInfo(client: TSDKClientModule, emptyClient: TSDKClientModule, rootAddr: String) async throws -> ToncoinJettonInfo {
        let rootAddr: String = try await Everscale.tonConvertAddrToEverFormat(client, rootAddr)
        let walletInfoResult = try await runGetMethod(client: client, emptyClient: emptyClient, addr: rootAddr, method: "get_jetton_data")
        
        /// (total_supply, -1, admin_address, content, jetton_wallet_code)
        let contentPosition: Int = 3
        guard
            let arr = walletInfoResult.toJson()?.toDictionary()?["output"] as? [Any],
            arr.count >= contentPosition + 1,
            let boc = (arr[contentPosition] as? [String: Any])?["value"] as? String
        else {
            throw makeError(TSDKClientError("Jetton Content not found"))
        }
        
        let tagResult: TSDKResultOfDecodeBoc = try await client.abi.decode_boc(
            .init(params: [
                .init(name: "tag", type: "uint8")
            ], boc: boc, allow_partial: true))
        guard
            let tag = (tagResult.toJson()!.toDictionary()?["data"] as? [String: Any])?["tag"] as? String
        else {
            throw makeError(TSDKClientError("Jetton tag not found"))
        }
        
        var jettonInfo: ToncoinJettonInfo = .init(decimals: 9)
        if tag == "0" {
            /// IF OFF-CHAIN TAG == 0
            let params: TSDKParamsOfDecodeBoc = .init(params: [
                .init(name: "tag", type: "uint8"),
                .init(name: "data", type: "map(uint256,cell)"),
            ], boc: boc, allow_partial: true)
            let result: TSDKResultOfDecodeBoc = try await client.abi.decode_boc(params)
            guard
                let metaData = ((result.toJson()!.toDictionary()?["data"] as? [String: Any])?["data"] as? [String: Any])
            else {
                throw makeError(TSDKClientError("Jetton meta data not found"))
            }
            /// decimals
            if let decimalsBoc = metaData[TONCOIN_JETTON_DECIMALS] as? String {
                let cellB = TvmCellBuilder().storeCellRefFromBoc(value: decimalsBoc).build()
                let newBoc = try await client.boc.encode_boc(.init(builder: cellB)).boc
                let result: TSDKResultOfDecodeBoc = try await client.abi.decode_boc(
                    .init(params: [
                        .init(name: "someName", type: "string")
                    ], boc: newBoc, allow_partial: true))
                
                if
                    let decimalsString = (result.toJson()?.toDictionary()?["data"] as? [String: Any])?["someName"] as? String,
                    let decimals = Int(try catFirstBytes(badString: decimalsString, bytesCount: 1))
                {
                    jettonInfo = .init(decimals: decimals)
                }
            }
            /// name
            if let nameBoc = metaData[TONCOIN_JETTON_NAME] as? String {
                let cellB = TvmCellBuilder().storeCellRefFromBoc(value: nameBoc).build()
                let newBoc = try await client.boc.encode_boc(.init(builder: cellB)).boc
                let result: TSDKResultOfDecodeBoc = try await client.abi.decode_boc(
                    .init(params: [
                        .init(name: "someName", type: "string")
                    ], boc: newBoc, allow_partial: true))
                if let name = (result.toJson()?.toDictionary()?["data"] as? [String: Any])?["someName"] as? String {
                    jettonInfo.name = try catFirstBytes(badString: name, bytesCount: 1)
                }
            }
            /// symbol
            if let symbolBoc = metaData[TONCOIN_JETTON_SYMBOL] as? String {
                let cellB = TvmCellBuilder().storeCellRefFromBoc(value: symbolBoc).build()
                let newBoc = try await client.boc.encode_boc(.init(builder: cellB)).boc
                let result: TSDKResultOfDecodeBoc = try await client.abi.decode_boc(
                    .init(params: [
                        .init(name: "someName", type: "string")
                    ], boc: newBoc, allow_partial: true))
                
                if let symbol = (result.toJson()?.toDictionary()?["data"] as? [String: Any])?["someName"] as? String {
                    jettonInfo.symbol = try catFirstBytes(badString: symbol, bytesCount: 1)
                }
            }
            /// image
            if let symbolBoc = metaData[TONCOIN_JETTON_IMAGE] as? String {
                let cellB = TvmCellBuilder().storeCellRefFromBoc(value: symbolBoc).build()
                let newBoc = try await client.boc.encode_boc(.init(builder: cellB)).boc
                let result: TSDKResultOfDecodeBoc = try await client.abi.decode_boc(
                    .init(params: [
                        .init(name: "someName", type: "string")
                    ], boc: newBoc, allow_partial: true))
                
                if let image = (result.toJson()?.toDictionary()?["data"] as? [String: Any])?["someName"] as? String {
                    jettonInfo.image = try catFirstBytes(badString: image, bytesCount: 1)
                }
            }
        } else if tag == "1" {
            /// IF ON-CHAIN TAG == 1
            let cellB = TvmCellBuilder().storeCellRefFromBoc(value: boc).build()
            let newBoc = try await client.boc.encode_boc(.init(builder: cellB)).boc
            let result: TSDKResultOfDecodeBoc = try await client.abi.decode_boc(
                .init(params: [
                    .init(name: "someName", type: "string")
                ], boc: newBoc, allow_partial: true))
            
            guard
                let value = (result.toJson()!.toDictionary()?["data"] as? [String: Any])?["someName"] as? String
            else {
                throw makeError(TSDKClientError("Jetton URL not found"))
            }
            let url = try catFirstBytes(badString: value, bytesCount: 1)
            
            if url[#"ipfs"#] {
                let ipfsUrl: String = "\(TONCOIN_JETTON_IPFS)/\(url.replace(#"^ipfs://"#, ""))"
                let netResult = try await Net.sendRequest(url: ipfsUrl, method: "GET")
                if let model = String(data: netResult.data, encoding: .utf8)?.toModel(ToncoinJettonInfoModel.self) {
                    jettonInfo.name = model.name
                    jettonInfo.symbol = model.symbol
                    jettonInfo.decimals = model.decimals ?? 9
                    if (model.image ?? model.image_data) != nil {
                        jettonInfo.image = "\(TONCOIN_JETTON_IPFS)/\((model.image ?? model.image_data)!.replace(#"^ipfs://"#, ""))"
                    }
                } else {
                    throw makeError(TSDKClientError("Jetton meta data not found"))
                }
            } else {
                let netResult = try await Net.sendRequest(url: url, method: "GET")
                if let model = String(data: netResult.data, encoding: .utf8)?.toModel(ToncoinJettonInfoModel.self) {
                    jettonInfo.name = model.name
                    jettonInfo.symbol = model.symbol
                    jettonInfo.decimals = model.decimals ?? 9
                    jettonInfo.image = model.image
                } else {
                    throw makeError(TSDKClientError("Jetton meta data not found"))
                }
            }
        } else {
            throw makeError(TSDKClientError("Unknown jetton tag"))
        }
        
        if jettonInfo.name.isEmpty || jettonInfo.symbol.isEmpty {
            throw makeError(TSDKClientError("Bad jetton meta data"))
        }
        
        return jettonInfo
    }
}
