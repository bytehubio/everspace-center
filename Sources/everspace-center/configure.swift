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
    let env = try Environment.detect()
    app.logger.warning("\(env)")
    guard let vaporStringPort = Environment.get("vapor_port"), let vaporPort = Int(vaporStringPort) else {
        fatalError("Set vapor_port to .env.your_evironment")
    }
    guard let vaporIp = Environment.get("vapor_ip") else { fatalError("Set vapor_ip to .env.your_evironment") }
    
    /// START VAPOR CONFIGURING
    app.http.server.configuration.address = BindAddress.hostname(vaporIp, port: vaporPort)
    #if os(Linux)
        app.logger.logLevel = .warning
    #else
        app.logger.logLevel = .debug
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
    app.middleware.use(RouteLoggingMiddleware())
    app.middleware.use(CustomFileMiddleware(publicDirectory: "Public"))
    app.middleware.use(CustomErrorMiddleware.default(environment: try Environment.detect()))
    /// ROUTES
    try routes(app)
}
