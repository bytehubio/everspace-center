//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 01.04.2023.
//

import Foundation
import Vapor


var Domain: String = "https://everspace.center"
var VAPOR_PORT: Int!
var VAPOR_IP: String!
var TONCOIN_JETTON_IPFS: String = ""

let TONCOIN_JETTON_NAME = "0x82a3537ff0dbce7eec35d69edc3a189ee6f17d82f353a553f9aa96cb0be3ce89"
let TONCOIN_JETTON_DESCRIPTION = "0xc9046f7a37ad0ea7cee73355984fa5428982f8b37c8f7bcec91f7ac71a7cd104"
let TONCOIN_JETTON_SYMBOL = "0xb76a7ca153c24671658335bbd08946350ffc621fa1c516e7123095d4ffd5c581"
let TONCOIN_JETTON_DECIMALS = "0xee80fd2f1e03480e2282363596ee752d7bb27f50776b95086a0279189675923e"
let TONCOIN_JETTON_IMAGE = "0x6105d6cc76af400325e94d588ce511be5bfdbb73b437dc51eca43917d7a43e3d"

let API_KEY_NAME: String = "X-API-KEY"
let EVERSCALE_SDK_DOMAIN_ENV: String = "everscale_mainnet"
let EVERSCALE_DEVNET_SDK_DOMAIN_ENV: String = "everscale_devnet"
let EVERSCALE_RFLD_SDK_DOMAIN_ENV: String = "everscale_rfld"
let VENOM_SDK_DOMAIN_ENV: String = "venom"
let VENOM_TESTNET_SDK_DOMAIN_ENV: String = "venom_testnet"
let TONCOIN_SDK_DOMAIN_ENV: String = "toncoin_mainnet"
let TONCOIN_TESTNET_SDK_DOMAIN_ENV: String = "toncoin_testnet"

var NETWORKS_SDK_DOMAINS: [String: String] = .init()

var PG_HOST: String = ""
var PG_PORT: Int = 0
var PG_USER: String = ""
var PG_PSWD: String = ""
var PG_DB_NAME: String = ""
//var PG_DB_CONNECTIONS: Int = Int(Double(System.coreCount))
var PG_DB_CONNECTIONS: Int = 5


func getAllEnvConstants() throws {
    let env = try Environment.detect()
    if env.name != "production" {
        Domain = "http://127.0.0.1:8181"
    }
    app.logger.warning("\(env)")
    guard let vaporStringPort = Environment.get("vapor_port"), let variable_1 = Int(vaporStringPort) else {
        fatalError("Set vapor_port to .env.\(env)")
    }
    VAPOR_PORT = variable_1
    
    guard let variable_2 = Environment.get("vapor_ip") else { fatalError("Set vapor_ip to .env.\(env)") }
    VAPOR_IP = variable_2
    
    guard let variable_3 = Environment.get("TONCOIN_JETTON_IPFS") else { fatalError("Set TONCOIN_JETTON_IPFS to .env.\(env)") }
    TONCOIN_JETTON_IPFS = variable_3
    
    guard let variable_4 = Environment.get(EVERSCALE_SDK_DOMAIN_ENV) else { fatalError("Set \(EVERSCALE_SDK_DOMAIN_ENV) to .env.\(env)") }
    NETWORKS_SDK_DOMAINS[EVERSCALE_SDK_DOMAIN_ENV] = variable_4
    
    guard let variable_5 = Environment.get(EVERSCALE_DEVNET_SDK_DOMAIN_ENV) else { fatalError("Set \(EVERSCALE_DEVNET_SDK_DOMAIN_ENV) to .env.\(env)") }
    NETWORKS_SDK_DOMAINS[EVERSCALE_DEVNET_SDK_DOMAIN_ENV] = variable_5
    
    guard let variable_6 = Environment.get(EVERSCALE_RFLD_SDK_DOMAIN_ENV) else { fatalError("Set \(EVERSCALE_RFLD_SDK_DOMAIN_ENV) to .env.\(env)") }
    NETWORKS_SDK_DOMAINS[EVERSCALE_RFLD_SDK_DOMAIN_ENV] = variable_6
    
    guard let variable_7 = Environment.get(VENOM_SDK_DOMAIN_ENV) else { fatalError("Set \(VENOM_SDK_DOMAIN_ENV) to .env.\(env)") }
    NETWORKS_SDK_DOMAINS[VENOM_SDK_DOMAIN_ENV] = variable_7
    
    guard let variable_8 = Environment.get(VENOM_TESTNET_SDK_DOMAIN_ENV) else { fatalError("Set \(VENOM_TESTNET_SDK_DOMAIN_ENV) to .env.\(env)") }
    NETWORKS_SDK_DOMAINS[VENOM_TESTNET_SDK_DOMAIN_ENV] = variable_8
    
    guard let variable_9 = Environment.get(TONCOIN_SDK_DOMAIN_ENV) else { fatalError("Set \(TONCOIN_SDK_DOMAIN_ENV) to .env.\(env)") }
    NETWORKS_SDK_DOMAINS[TONCOIN_SDK_DOMAIN_ENV] = variable_9
    
    guard let variable_10 = Environment.get("PG_HOST") else { fatalError("Set PG_HOST to .env.\(env)") }
    PG_HOST = variable_10
    
    guard
            let dbPortString = Environment.get("PG_PORT"),
            let variable_11 = Int(dbPortString)
    else { fatalError("Set PG_PORT to \((try? Environment.detect().name) ?? ".env.\(env)")") }
    PG_PORT = variable_11
    
    guard let variable_12 = Environment.get("PG_USER") else { fatalError("Set PG_USER to .env.\(env)") }
    PG_USER = variable_12
    
    guard let variable_13 = Environment.get("PG_PSWD") else { fatalError("Set PG_PSWD to .env.\(env)") }
    PG_PSWD = variable_13
    
    guard let variable_14 = Environment.get("PG_DB_NAME") else { fatalError("Set PG_DB_NAME to .env.\(env)") }
    PG_DB_NAME = variable_14
    
    guard let variable_15 = Environment.get(TONCOIN_TESTNET_SDK_DOMAIN_ENV) else { fatalError("Set \(TONCOIN_TESTNET_SDK_DOMAIN_ENV) to .env.\(env)") }
    NETWORKS_SDK_DOMAINS[TONCOIN_TESTNET_SDK_DOMAIN_ENV] = variable_15
}
