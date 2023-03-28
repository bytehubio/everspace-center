//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 28.03.2023.
//

import Foundation
import EverscaleClientSwift
import SwiftExtensionsPack
import Vapor

extension Everscale {
    
    struct LastMasterBlockResponse: Content {
        var id: String = "..."
        var seq_no: Double = 1
        var file_hash: String = "..."
        var shard: String = "..."
        var workchain_id: Int = 1
    }
    
    struct GetBlockRequest: Content {
        var workchain_id: Int = 1
        var shard: String = "..."
        var seq_no: Int = 1
    }
    
    struct BlockResponse: Content {
        var id: String = "..."
        var seq_no: Double = 1
        var file_hash: String = "..."
        var shard: String = "..."
        var workchain_id: Int = 1
        var master_ref: MasterRef? = .init()
        var global_id: Int = 1
        var version: Double = 1
        var after_merge: Bool = false
        var after_split: Bool = false
        var before_split: Bool = false
        var want_merge: Bool = false
        var want_split: Bool = false
        var gen_validator_list_hash_short: Double = 1
        var gen_catchain_seqno: Double = 1
        var key_block: Bool = false
        var prev_key_block_seqno: Double = 1
        var start_lt: String = "..."
        var end_lt: String = "..."
        var gen_utime: Double = 1
        var vert_seq_no: Double = 1
        var prev_ref: PrevRef = .init()
        
        struct MasterRef: Content {
            var file_hash: String = "..."
            var root_hash: String = "..."
            var seq_no: Double = 1
        }
        
        struct PrevRef: Content {
            var file_hash: String = "..."
            var root_hash: String = "..."
            var seq_no: Double = 1
        }
    }
    
    struct RawBlockResponse: Content {
        var id: String = "..."
        var seq_no: Double = 1
        var file_hash: String = "..."
        var shard: String = "..."
        var workchain_id: Int = 1
        var boc: String = "..."
    }
    
    struct LookupBlockRequest: Content {
        var workchain_id: Int = 1
        var shard: String = "..."
        var seq_no: Int? = 1
        var start_lt: String? = "..."
        var gen_utime: Double? = 1
    }
    
    struct LookupBlockResponse: Content {
        var id: String = "..."
        var workchain_id: Int = 1
        var shard: String = "..."
        var seq_no: Int = 1
        var start_lt: String = "..."
        var gen_utime: Double = 1
        var file_hash: String = "..."
    }
    
    class func getLastMasterBlock(client: TSDKClientModule) async throws -> LastMasterBlockResponse {
        let out = try await client.net.query(TSDKParamsOfQuery(query: """
        query {
          blocks(
            filter: {
              workchain_id: {eq: -1}
            },
            limit: 1,
            orderBy: {
              path: "seq_no", direction: DESC
            }
          ) {
            id
            seq_no
            file_hash
            shard
            workchain_id
          }
        }
        """))
        
        guard let result = try ((out.result.toDictionary()?["data"] as? [String: Any])?["blocks"] as? [[String: Any]])?.first?.toJSON()
        else {
            throw makeError(AppError.mess("Block not found"))
        }
        
        return try result.toModel(LastMasterBlockResponse.self)
    }
    
    class func getBlock(client: TSDKClientModule, content: GetBlockRequest) async throws -> BlockResponse {
        let out = try await client.net.query(TSDKParamsOfQuery(query: """
        query {
          blocks(
            filter: {
              workchain_id: {eq: \(content.workchain_id)},
              shard: {eq: "\(content.shard)"},
              seq_no: {eq: \(content.seq_no)}
            }
          ) {
            id
            seq_no
            file_hash
            shard
            workchain_id
            master_ref {
              file_hash
              root_hash
              seq_no
            }
            global_id
            version
            after_merge
            after_split
            before_split
            want_merge
            want_split
            gen_validator_list_hash_short
            gen_catchain_seqno
            key_block
            prev_key_block_seqno
            start_lt
            end_lt
            gen_utime
            vert_seq_no
            prev_ref {
              file_hash
              root_hash
              seq_no
            }
          }
        }
        """))
        
        guard let result = try ((out.result.toDictionary()?["data"] as? [String: Any])?["blocks"] as? [[String: Any]])?.first?.toJSON()
        else {
            throw makeError(AppError.mess("Block not found"))
        }
        
        return try result.toModel(BlockResponse.self)
    }
    
    class func getRawBlock(client: TSDKClientModule, content: GetBlockRequest) async throws -> RawBlockResponse {
        let out = try await client.net.query(TSDKParamsOfQuery(query: """
        query {
          blocks(
            filter: {
              workchain_id: {eq: \(content.workchain_id)},
              shard: {eq: "\(content.shard)"},
              seq_no: {eq: \(content.seq_no)}
            }
          ) {
            id
            seq_no
            file_hash
            shard
            workchain_id
            boc
          }
        }
        """))
        
        guard let result = try ((out.result.toDictionary()?["data"] as? [String: Any])?["blocks"] as? [[String: Any]])?.first?.toJSON()
        else {
            throw makeError(AppError.mess("Block not found"))
        }
        
        return try result.toModel(RawBlockResponse.self)
    }
    
    class func lookupBlock(client: TSDKClientModule, content: LookupBlockRequest) async throws -> LookupBlockResponse {
        if content.seq_no == nil && content.start_lt == nil && content.gen_utime == nil {
            throw makeError(AppError.mess("seq_no, start_lt or gen_utime should be defined"))
        }
        let out = try await client.net.query(TSDKParamsOfQuery(query: """
        query {
          blocks(
            filter: {
              workchain_id: {eq: \(content.workchain_id)},
              \(content.seq_no != nil ? "seq_no: {eq: \(content.seq_no!)}," : "")
              \(content.start_lt != nil ? "start_lt: {eq: \"\(content.start_lt!)\"}," : "")
              \(content.gen_utime != nil ? "gen_utime: {eq: \(content.gen_utime!)}," : "")
              shard: {eq: \"\(content.shard)\"}
            }
          ) {
            id
            workchain_id
            seq_no
            file_hash
            shard
            gen_utime
            start_lt
          }
        }
        """))
        
        guard let result = try ((out.result.toDictionary()?["data"] as? [String: Any])?["blocks"] as? [[String: Any]])?.first?.toJSON()
        else {
            throw makeError(AppError.mess("Block not found"))
        }
        
        return try result.toModel(LookupBlockResponse.self)
    }
}
