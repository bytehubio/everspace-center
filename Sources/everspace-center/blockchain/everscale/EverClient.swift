//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.03.2023.
//

import Foundation
import EverscaleClientSwift
import Vapor

public final class EverClient {
    
    public static var shared: EverClient = {
        try! .init(clientConfig: EverClient.makeClientConfig())
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
    
    public init(clientConfig: TSDKClientConfig) throws {
        self.client = try TSDKClientModule(config: clientConfig)
    }
    
    public static func makeClientConfig() -> TSDKClientConfig {
        let networkConfig: TSDKNetworkConfig = .init(server_address: nil,
                                                     endpoints: try! EverClient.getNetwork(networkName: "mainnet")
        )
        return .init(network: networkConfig, crypto: nil, abi: nil, boc: nil)
    }
    
    public func refreshClient() {
        client = try! TSDKClientModule(config: Self.makeClientConfig())
    }
}
