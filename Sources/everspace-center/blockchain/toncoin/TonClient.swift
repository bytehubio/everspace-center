//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 26.03.2023.
//

import Foundation
import EverscaleClientSwift
import Vapor

public final class ToncoinClient {
    
    public static var shared: EverClient = {
        try! .init(clientConfig: EverClient.makeClientConfig(), emptyClient: ToncoinClient.makeEmptyClientConfig())
    }()
 
    private class func getNetwork(networkName: String) throws -> [String] {
        guard let json = Environment.get(networkName) else { throw AppError(reason: "\(networkName) is not defined for env \(try Environment.detect().name)")  }
        let data = json.data(using: .utf8)
        guard let dict: [String] = try JSONSerialization.jsonObject(with: data ?? "{}".data(using: .utf8)!, options: []) as? [String] else {
            throw AppError(reason: "\(json) is not Array of String")
        }
        
        return dict
    }
    
    var client: TSDKClientModule
    var emptyClient: TSDKClientModule
    
    public init(clientConfig: TSDKClientConfig, emptyClient: TSDKClientConfig) throws {
        self.client = try TSDKClientModule(config: clientConfig)
        self.emptyClient = try TSDKClientModule(config: clientConfig)
    }
    
    public static func makeClientConfig() -> TSDKClientConfig {
        let networkConfig: TSDKNetworkConfig = .init(server_address: nil,
                                                     endpoints: try! Self.getNetwork(networkName: "toncoin_mainnet")
        )
        return .init(network: networkConfig, crypto: nil, abi: nil, boc: nil)
    }
    
    public static func makeEmptyClientConfig() -> TSDKClientConfig {
        .init(network: .init())
    }
    
    public func refreshClient() {
        client = try! TSDKClientModule(config: Self.makeClientConfig())
    }
}
