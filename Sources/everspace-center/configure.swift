//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 21.05.2021.
//


import Foundation
import Vapor
import FileUtils
import IkigaJSON

public func configure(_ app: Application) throws {
    /// GET ENV
    try getAllEnvConstants()

    /// START VAPOR CONFIGURING
    app.http.server.configuration.address = BindAddress.hostname(VAPOR_IP, port: VAPOR_PORT)
    #if os(Linux)
    app.logger.logLevel = .warning
    #else
    app.logger.logLevel = .notice
    #endif
    
    /// CUSTOM JSON ENCODER
//    var decoder = IkigaJSONDecoder()
//    decoder.settings.dateDecodingStrategy = .iso8601
//    ContentConfiguration.global.use(decoder: decoder, for: .json)
    var encoder = IkigaJSONEncoder()
    encoder.settings.dateDecodingStrategy = .iso8601
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    
    /// CUSTOM ERROR
    app.middleware = .init()
    app.middleware.use(RouteLoggingMiddleware()) // 1
    app.middleware.use(CustomFileMiddleware(publicDirectory: "Public"))
    app.middleware.use(CustomErrorMiddleware.default(environment: try Environment.detect()))
    app.middleware.use(ApiKeyMiddleware())
    /// ROUTES
    try routes(app)
}
