//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 01.04.2023.
//

import Foundation
import Vapor


var Domain: String = "https://everspace.center"
var Vapor_Port: Int!
var Vapor_Ip: String!
var TONCOIN_JETTON_IPFS: String = ""

public let TONCOIN_JETTON_NAME = "0x82a3537ff0dbce7eec35d69edc3a189ee6f17d82f353a553f9aa96cb0be3ce89"
public let TONCOIN_JETTON_DESCRIPTION = "0xc9046f7a37ad0ea7cee73355984fa5428982f8b37c8f7bcec91f7ac71a7cd104"
public let TONCOIN_JETTON_SYMBOL = "0xb76a7ca153c24671658335bbd08946350ffc621fa1c516e7123095d4ffd5c581"
public let TONCOIN_JETTON_DECIMALS = "0xee80fd2f1e03480e2282363596ee752d7bb27f50776b95086a0279189675923e"
public let TONCOIN_JETTON_IMAGE = "0x6105d6cc76af400325e94d588ce511be5bfdbb73b437dc51eca43917d7a43e3d"



func getAllEnvConstants() throws {
    let env = try Environment.detect()
    if env.name != "production" {
        Domain = "http://127.0.0.1:8181"
    }
    app.logger.warning("\(env)")
    guard let vaporStringPort = Environment.get("vapor_port"), let variable_1 = Int(vaporStringPort) else {
        fatalError("Set vapor_port to .env.your_evironment")
    }
    Vapor_Port = variable_1
    
    guard let variable_2 = Environment.get("vapor_ip") else { fatalError("Set vapor_ip to .env.your_evironment") }
    Vapor_Ip = variable_2
    
    guard let variable_3 = Environment.get("TONCOIN_JETTON_IPFS") else { fatalError("Set TONCOIN_JETTON_IPFS to .env.your_evironment") }
    TONCOIN_JETTON_IPFS = variable_3
}
