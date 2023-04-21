//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.03.2023.
//

import Foundation
import EverscaleClientSwift
import Vapor

//protocol SDKClientPrtcl {
//    var client: TSDKClientModule { get }
//    var emptyClient: TSDKClientModule { get }
//}

public final class SDKClient {
    
    private class func getNetwork(networkName: String) throws -> [String] {
        guard let json = Environment.get(networkName) else { throw AppError(reason: "\(networkName) is not defined for env \(try Environment.detect().name)")  }
        let data = json.data(using: .utf8)
        guard let arr: [String] = try JSONSerialization.jsonObject(with: data ?? "{}".data(using: .utf8)!, options: []) as? [String] else {
            throw AppError(reason: "\(json) is not Array of String")
        }
        
        return arr
    }
    
//    var client: TSDKClientModule! = nil
//    var emptyClient: TSDKClientModule! = nil
    
//    public init(clientConfig: TSDKClientConfig) throws {
//        self.client = try TSDKClientModule(config: clientConfig)
//        self.emptyClient = Self.makeEmptyClient()
//    }
//
//    public init(_ endpoints: [String]) throws {
//        self.client = try TSDKClientModule(config: Self.makeClientConfig(endpoints))
//        self.emptyClient = Self.makeEmptyClient()
//    }
    
    public static func makeClientConfig(name: String) -> TSDKClientConfig {
        let networkConfig: TSDKNetworkConfig = .init(endpoints: try! SDKClient.getNetwork(networkName: name),
                                                     out_of_sync_threshold: 90000)
        return .init(network: networkConfig, crypto: nil, abi: .init(message_expiration_timeout: 180000), boc: nil)
    }
    
    public static func makeClientConfig(_ endpoints: [String]) -> TSDKClientConfig {
        let networkConfig: TSDKNetworkConfig = .init(endpoints: endpoints,
                                                     out_of_sync_threshold: 90000)
        return .init(network: networkConfig, crypto: nil, abi: .init(message_expiration_timeout: 180000), boc: nil)
    }
    
    private static func makeEmptyClientConfig() -> TSDKClientConfig {
        .init(network: .init(out_of_sync_threshold: 90000), abi: .init(message_expiration_timeout: 180000))
    }
    
    public static func makeEmptyClient() -> TSDKClientModule {
        try! TSDKClientModule(config: SDKClient.makeEmptyClientConfig())
    }
    
    public static func getSDKClient(_ req: Request, _ network: String) throws -> TSDKClientModule {
        guard let apiKey = req.headers[API_KEY_NAME].first else {
            throw AppError("\(API_KEY_NAME) not found.")
        }
        return try makeClient(apiKey: apiKey, network: network)
    }
    
    public static func makeClient(apiKey: String?, network: String) throws -> TSDKClientModule {
        guard let sdk_domain = NETWORKS_SDK_DOMAINS[network] else {
            throw AppError("\(network) network domain not found")
        }
        var url: String = ""
        if network == VENOM_SDK_DOMAIN_ENV || network == EVERSCALE_RFLD_SDK_DOMAIN_ENV {
            url = "\(sdk_domain)"
        } else {
            guard let apiKey = apiKey else {
                throw AppError("apiKey not found.")
            }
            url = "\(sdk_domain)/\(apiKey)"
        }
        return try TSDKClientModule(config: Self.makeClientConfig([url]))
    }
}

