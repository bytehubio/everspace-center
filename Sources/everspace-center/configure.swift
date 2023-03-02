//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 21.05.2021.
//


import Foundation
import Vapor
import FCM
import FileUtils

public func configure(_ app: Application) throws {

    /// Vapor config
    /// print enviroment
    let env = try Environment.detect()
    app.logger.warning("\(env)")
    
    guard let vaporStringPort = Environment.get("vapor_port"),
          let vaporPort = Int(vaporStringPort)
    else { fatalError("Set vapor_port to .env.your_evironment") }
    guard let vaporIp = Environment.get("vapor_ip") else { fatalError("Set vapor_ip to .env.your_evironment") }
    app.http.server.configuration.address = BindAddress.hostname(vaporIp, port: vaporPort)
    app.logger.logLevel = .notice    
    try routes(app)
}
