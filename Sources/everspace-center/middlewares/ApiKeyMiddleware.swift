//
//  File.swift
//
//
//  Created by Oleh Hudeichuk on 23.03.2023.
//

import Foundation
import Vapor
import SwiftExtensionsPack
import SwiftRegularExpression

public final class ApiKeyMiddleware: Middleware {

    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        let url = request.url.string.lowercased()
        /// SKIP VENOM MAINNET
        if url.contains("venom") && !url[#"testnet"#] {
            return next.respond(to: request)
        }
        if url.contains("rfld") {
            return next.respond(to: request)
        }
        if url[#"\w\/\w"#] {
            if request.headers[API_KEY_NAME].first == nil {
                return request.eventLoop.makeFailedFuture(AppError("Authorization failed. Please add X-API-KEY token to headers of request."))
            }
        }
        
        return next.respond(to: request)
    }
}
