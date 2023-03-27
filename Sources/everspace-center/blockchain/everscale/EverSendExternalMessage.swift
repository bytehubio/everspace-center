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

extension EverClient {
    
    public struct SendExternalMessage: Codable {
        var shard_block_id: String = ""
    }
    
    class func sendExternalMessage(client: TSDKClientModule = EverClient.shared.client,
                                   boc: String
    ) async throws -> SendExternalMessage {
        let params: TSDKParamsOfSendMessage = .init(message: boc, abi: nil, send_events: false)
        let result: TSDKResultOfSendMessage = try await client.processing.send_message(params)
        return SendExternalMessage(shard_block_id: result.shard_block_id)
    }
}
