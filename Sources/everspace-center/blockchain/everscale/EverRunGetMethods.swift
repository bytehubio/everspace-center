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
    
    public struct RunGetMethodFift: Codable, Content {
        var address: String = "..."
        var method: String = "..."
        var params: [String]? = []
    }
    
    public struct RunGetMethodAbi: Codable, Content {
        var address: String = "..."
        var method: String = "..."
        var jsonParams: String? = "..."
        var abi: String = "..."
    }
    
    public struct RunGetMethodFiftResponse: Codable, Content {
        var result: String = ""
    }
    
    class func runGetMethodFift(client: TSDKClientModule,
                                emptyClient: TSDKClientModule,
                                address: String,
                                method: String,
                                params: [String]? = nil
    ) async throws -> RunGetMethodFiftResponse {
        let address: String = try await tonConvertAddrToEverFormat(client: emptyClient, address.everAddrLowercased)
        let response = try await everspace_center.runGetMethodFift(client: client,
                                                  emptyClient: emptyClient,
                                                  addr: address,
                                                  method: method,
                                                  params: params)
        return .init(result: response.output.toJSON())
    }
    
    class func runGetMethodAbi(client: TSDKClientModule,
                               emptyClient: TSDKClientModule,
                               address: String,
                               method: String,
                               jsonParams: String? = nil,
                               abi: String
    ) async throws -> RunGetMethodFiftResponse {
        let address: String = try await tonConvertAddrToEverFormat(client: emptyClient, address.everAddrLowercased)
        guard let methodParams = jsonParams?.toDictionary() else {
            throw makeError(AppError.mess("Bad json params. Convert params to dictionary failed"))
        }
        let response = try await everspace_center.runGetMethodAbi(client: client,
                                                                  emptyClient: emptyClient,
                                                                  addr: address,
                                                                  method: method,
                                                                  params: methodParams,
                                                                  abi: abi)
        return .init(result: response)
    }
}
