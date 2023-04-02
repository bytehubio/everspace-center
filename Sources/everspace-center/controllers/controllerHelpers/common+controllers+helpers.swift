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
        guard let sdk_domain = NETWORKS_SDK_DOMAINS[network] else {
            throw AppError("\(network) network domain not found")
        }
        return try SDKClient(["\(sdk_domain)/\(apiKey)"])
    }
}
