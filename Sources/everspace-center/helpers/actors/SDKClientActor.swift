//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 20.04.2023.
//

import Foundation
import EverscaleClientSwift
import Vapor

actor SDKClientActor {
    private var _emptyClient: TSDKClientModule = SDKClient.makeEmptyClient()

    func client(_ apiKey: String?, _ network: String) throws -> TSDKClientModule {
        #warning("ADD Enum")
        switch network {
        case EVERSCALE_SDK_DOMAIN_ENV:
            return everClient
        case EVERSCALE_DEVNET_SDK_DOMAIN_ENV:
            return everDevClient
        case EVERSCALE_RFLD_SDK_DOMAIN_ENV:
            return everFLDClient
        case VENOM_SDK_DOMAIN_ENV:
            return everVenomClient
        case VENOM_TESTNET_SDK_DOMAIN_ENV:
            return everVenomTestnetClient
        case VENOM_DEVNET_SDK_DOMAIN_ENV:
            return everVenomDevnetClient
        case TONCOIN_SDK_DOMAIN_ENV:
            return everToncoinClient
        case TONCOIN_TESTNET_SDK_DOMAIN_ENV:
            return everToncoinTestnetClient
        default:
            return try SDKClient.makeClient(apiKey: apiKey, network: network)
        }
//        return try SDKClient.makeClient(apiKey: apiKey, network: network)
    }
    
    func client(_ req: Request, _ network: String) async throws -> TSDKClientModule {
        guard let apiKey = req.headers[API_KEY_NAME].first else {
            throw AppError("\(API_KEY_NAME) not found.")
        }
        return try client(apiKey, network)
    }
    
    func emptyClient() -> TSDKClientModule {
        _emptyClient
    }
}
