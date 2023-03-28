//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 27.03.2023.
//

import Foundation
import EverscaleClientSwift
import BigInt
import SwiftExtensionsPack
import Vapor

extension Everscale {
    
    public struct SendExternalMessage: Codable {
        var shard_block_id: String = ""
    }
    
    class func sendExternalMessage(client: TSDKClientModule,
                                   boc: String
    ) async throws -> SendExternalMessage {
        let params: TSDKParamsOfSendMessage = .init(message: boc, abi: nil, send_events: false)
        let result: TSDKResultOfSendMessage = try await client.processing.send_message(params)
        return SendExternalMessage(shard_block_id: result.shard_block_id)
    }
    
    class func sendExternalMessageGQL(client: TSDKClientModule,
                                      boc: String
    ) async throws -> SendExternalMessage {
        let hash = try await client.boc.get_boc_hash(TSDKParamsOfGetBocHash(boc: boc))
        let query = try await client.net.query(TSDKParamsOfQuery(query: "mutation {postRequests(requests: {id: \"\(hash.hash)\", body: \"\(boc)\"})}"))
        guard let shard_block_id = ((query.result.toDictionary()?["data"] as? [String: Any])?["postRequests"] as? [String])?.first else {
            throw makeError(AppError.mess("shard_block_id not found"))
        }
        return .init(shard_block_id: shard_block_id)
    }
}
