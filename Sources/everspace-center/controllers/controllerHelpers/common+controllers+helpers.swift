//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.04.2023.
//

import Foundation
import Vapor
import EverscaleClientSwift

extension RouteCollection {
    func getSDKClient(_ req: Request, _ network: String) throws -> SDKClient {
        guard let apiKey = req.headers[API_KEY_NAME].first else {
            throw AppError("\(API_KEY_NAME) not found.")
        }
        return try getSDKClient(apiKey: apiKey, network: network)
    }
    
    func getSDKClient(apiKey: String?, network: String) throws -> SDKClient {
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
        return try SDKClient([url])
    }
}
